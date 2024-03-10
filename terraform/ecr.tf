resource "aws_ecr_repository" "hackit_ecr_repository" {
  name                 = "hackit_dev"
  image_tag_mutability = "MUTABLE"
}
