# Terraform

В ходе выполнения домашнего задания к занятию "Terraform как инструмент для декларативного описания инфраструктуры" подготовлена отказоустойчивая облачная инфраструктура для последующей установки Wordpress.
Сначала мы настроили Yandex.Cloud и подготовили рабочую станцию для последующей работы.  
Создание манифестов терраформа.
## Провайдер
Начнем с манифеста, т.е файл provider.tf, который будет описывать к какому облачному провайдеру мы планируем обратиться. И передаем необходимые переменные для использования данного провайдера, токен, ID облака и ID каталога. Затем создадим файл файл variables.tf, в которым мы опишем какие переменные мы будем использовать в наших манифестах. 
Далее были созданы манифесты для наших ресурсов. 
## Виртуальные сети
Сначала создали виртуальную сеть и три её подсети, описанные в файле network.tf.
## Виртуальные машины
Были созданы манифесты для хостов, где будет разворачиваться WordPress. В файле wp-app.tf мы создаем два ресурса вида yandex_compute_instance - т.е. две виртуальные машины. В блоке metadata передается публичная часть ключа для подключения через SSH.
## Балансировщик трафика
Виртуальные машины у нас есть, далее был создан манифест lb.tf для балансировщика, который будет перенаправлять на них пользовательский трафик. Создали группу хостов, куда будем направлять трафик.
## База данных
В качестве бекэнда для WordPress-а мы будем использовать MySQL.
Для этого создаем в YC облачный кластер MySQL и опишем для этого соответствующий манифест db.tf.
## Output-переменные
И в завершении создали файл output.tf, где указали вывод запрошенной информации, которая может нам пригодится.
### Вывод: 
Запустив команду применения манифестов мы убедились, что кластер баз данных создан успешно.