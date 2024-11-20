terraform {
  backend "http" {
    address="https://gitlab.com/api/v4/projects/62791984/terraform/state/iacstate"
    lock_address="https://gitlab.com/api/v4/projects/62791984/terraform/state/iacstate/lock"
    unlock_address="https://gitlab.com/api/v4/projects/62791984/terraform/state/iacstate/lock"
    username="thesecretoftnesun"
    lock_method="POST"
    unlock_method="DELETE"
    retry_wait_min=5
  }
}