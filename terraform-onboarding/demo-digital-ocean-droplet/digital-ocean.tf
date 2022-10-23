provider "digitalocean" {
  token = "YOUR-TOKEN"
}


resource "digitalocean_droplet" "doinstance" {
  image  = "ubuntu-18-04-x64"
  name   = "prod"
  region = "nyc1"
  size   = "s-1vcpu-1gb"
}


/*
Ref: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet
/*