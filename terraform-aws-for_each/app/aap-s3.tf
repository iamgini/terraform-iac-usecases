# resource "aws_s3_bucket" "hub_store" {
#   bucket = "app-store-12345"
# #   acl    = "private"  # Options: private, public-read, public-read-write, authenticated-read
#   force_destroy = true
#   tags = {
#     Name        = "hub-store"
#     Environment = "Dev"
#   }
# }