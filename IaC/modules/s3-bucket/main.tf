resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "url-shortner-website"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static-website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id
  
  block_public_acls = false  # default false
  block_public_policy = false  # default false
  ignore_public_acls = false  # default false
  restrict_public_buckets = false  # public_bucket policies, default false
}



# locals {  # for file types of objects
#   content_types = {
#     "html" = "text/html",
#     "css"  = "text/css",
#     "js"   = "application/javascript"  # .js file is not working, idk why; have to debug
#   }
# }

# resource "aws_s3_object" "upload_objects" {
#   bucket = aws_s3_bucket.frontend_bucket.id
#   # for_each = fileset("website", "*")  # if have multiple files, if only html 

#   for_each  = fileset("website", "*.*")  // Iterate over files. * - root directry, ** - sub directories also, *.* - file with period in it
#   key           = each.value  // Name of the object once in the bucket
#   source        = "website/${each.value}"  // Path to each file
#   etag          = filemd5("/website/${each.value}")  // Check if the file has changed
#   # content_type  = "text/html"  # if only html, optional
#   content_type  = lookup(local.content_types, split(".", each.value)[1], "binary/octet-stream")  # iterate through each type, default binary/octet-stream
# }

# resource "aws_s3_object_copy" "test" {
#   bucket = "aws_s3_bucket.frontend_bucket.id"
#   for_each  = fileset("website", "*.*")  // Iterate over files. * - root directry, ** - sub directories also, *.* - file with period in it
#   key           = each.value  // Name of the object once in the bucket
#   source        = "website/${each.value}"  // Path to each file

#   content_type  = lookup(local.content_types, split(".", each.value)[1], "binary/octet-stream")  # iterate through each type, default binary/octet-stream
# }

# # to add varibles values; region, api_id in .js file
# # Read and process the template file
# # data "template_file" "js_template" {
# #   template = file("${path.module}/website/script.js")
# #   vars = {
# #     api_endpoint = "https://${var.api_id}.execute-api.${var.region}.amazonaws.com/shorten"
# #   }
# # }

# # # Create a new file with the changed value
# # resource "local_file" "js_rendered" {
# #   content  = data.template_file.js_template.rendered
# #   filename = "${path.module}/website/rendered_script.js"
# # }

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Principal = "*"
        Resource  = ["${aws_s3_bucket.frontend_bucket.arn}/*"],
      }
    ]
  })
}