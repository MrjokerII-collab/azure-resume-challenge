variable "content_types" {
  default = {
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".png"  = "image/png",
    ".jpg"  = "image/jpeg",
    ".md"   = "text/markdown"
  }
}

variable "storage_name"{
  default = "tfcloudresume1"
  type = string
}

variable "path_folder"{
  default = "C:/Users/Fred/Documents/IT/Cloudchall/Cloudchallenge-pythonv1/frontend"
  type = string
}
