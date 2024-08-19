#declare variables
variable "bucketname" {
    default = "myterraform-1st-bucket2024"
}

#create a S3 bucket
resource "aws_s3_bucket" "test" {
    bucket = var.bucketname
}

#to change ownership so no one can make changes to the bucket
resource "aws_s3_bucket_ownership_controls" "test_ownership" {
  bucket = aws_s3_bucket.test.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# to make bucket available to public
resource "aws_s3_bucket_public_access_block" "test_public_access" {
  bucket = aws_s3_bucket.test.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#to make contents of the bucket accessible to public
resource "aws_s3_bucket_acl" "test_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.test_ownership,
    aws_s3_bucket_public_access_block.test_public_access,
  ]

  bucket = aws_s3_bucket.test.id
  acl    = "public-read"
}


#to put the file to S3
resource "aws_s3_object" "test_index" {
  bucket = aws_s3_bucket.test.id
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "test_error" {
  bucket = aws_s3_bucket.test.id
  key    = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

# to configure static website in s3
resource "aws_s3_bucket_website_configuration" "test_config" {
  bucket = aws_s3_bucket.test.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.test_acl ]
}