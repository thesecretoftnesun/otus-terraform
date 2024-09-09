package test

import (
	"flag"
	"fmt"
	"io/ioutil"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"golang.org/x/crypto/ssh"
)

var folder = flag.String("folder", "", "Folder ID in Yandex.Cloud")
var sshKeyPath = flag.String("ssh-key-pass", "", "Private ssh key for access to virtual machines")

func TestEndToEndDeploymentScenario(t *testing.T) {
	fixtureFolder := "../"

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: fixtureFolder,

			Vars: map[string]interface{}{
				"yc_folder": *folder,
			},
		}

		test_structure.SaveTerraformOptions(t, fixtureFolder, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		fmt.Println("Run some tests...")
		terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)
		// загружает опции Terraform (которые были сохранены ранее) из указанной папки fixtureFolder.
		// (переменные, пути к файлам, и другие настройки).
		// test load balancer ip existing
		loadbalancerIPAddress := terraform.Output(t, terraformOptions, "load_balancer_public_ip")

		if loadbalancerIPAddress == "" {
			t.Fatal("Cannot retrieve the public IP address value for the load balancer.")
		}
		// test ssh connect
		vmLinuxPublicIPAddress := terraform.Output(t, terraformOptions, "vm_linux_public_ip_address")

		key, err := ioutil.ReadFile(*sshKeyPath)
		if err != nil {
			t.Fatalf("Unable to read private key: %v", err)
		}

		signer, err := ssh.ParsePrivateKey(key)
		if err != nil {
			t.Fatalf("Unable to parse private key: %v", err)
		}

		sshConfig := &ssh.ClientConfig{
			User: "ubuntu",
			Auth: []ssh.AuthMethod{
				ssh.PublicKeys(signer),
			},
			HostKeyCallback: ssh.InsecureIgnoreHostKey(),
		}

		sshConnection, err := ssh.Dial("tcp", fmt.Sprintf("%s:22", vmLinuxPublicIPAddress), sshConfig)
		if err != nil {
			t.Fatalf("Cannot establish SSH connection to vm-linux public IP address: %v", err)
		}

		defer sshConnection.Close()

		sshSession, err := sshConnection.NewSession()
		if err != nil {
			t.Fatalf("Cannot create SSH session to vm-linux public IP address: %v", err)
		}

		defer sshSession.Close()

		// Проверка ping
		err = sshSession.Run(fmt.Sprintf("ping -c 1 8.8.8.8"))
		if err != nil {
			t.Fatalf("Cannot ping 8.8.8.8: %v", err)
		}

		defer sshSession.Close()

		// Создаем новую SSH-сессию для установки MySQL клиента
		sshSession, err = sshConnection.NewSession()
		if err != nil {
			t.Fatalf("Cannot create SSH session for MySQL client installation: %v", err)
		}
		defer sshSession.Close()

		// Установка MySQL клиента
		installMySQLCommand := "sudo apt-get update && sudo apt-get install mysql-client -y"
		err = sshSession.Run(installMySQLCommand)
		if err != nil {
			t.Fatalf("Failed to install MySQL client: %v", err)
		}

		// Создаем новую SSH-сессию для выполнения команды MySQL
		sshSession, err = sshConnection.NewSession()
		if err != nil {
			t.Fatalf("Cannot create SSH session for MySQL: %v", err)
		}
		defer sshSession.Close()

		// Получаем параметры для подключения к базе данных MySQL из вывода Terraform
		dbUser := terraform.Output(t, terraformOptions, "db_user")
		dbPassword := terraform.Output(t, terraformOptions, "db_password")
		dbHost := terraform.OutputList(t, terraformOptions, "db_hosts")[0] // Используем первый хост
		dbName := terraform.Output(t, terraformOptions, "db_name")

		/// Команда для проверки подключения к MySQL
		checkDbCommand := fmt.Sprintf("mysql -u%s -p%s -h%s -e 'SHOW DATABASES;' %s", dbUser, dbPassword, dbHost, dbName)
		output, err := sshSession.CombinedOutput(checkDbCommand) // Используем CombinedOutput для получения stdout и stderr
		if err != nil {
			t.Fatalf("Failed to connect to MySQL database: %v, output: %s", err, output)
		}

		fmt.Println("MySQL database connection test successful, output:")
		fmt.Println(string(output))
	})

	test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)
		terraform.Destroy(t, terraformOptions)
	})
}
