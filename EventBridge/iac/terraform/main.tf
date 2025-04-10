provider "aws" {
  region = "us-east-1"
}

resource "aws_cloud_watch_event_bus" "mytestbus" {
    name = "mytestbus"
}
