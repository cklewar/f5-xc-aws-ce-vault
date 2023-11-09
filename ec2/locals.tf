locals {
  template_input_dir_path  = var.template_input_dir_path != "" ? var.template_input_dir_path : abspath("../../templates/")
  template_output_dir_path = var.template_output_dir_path != "" ? var.template_output_dir_path : abspath("../_out/")
  custom_tags              = merge(var.custom_tags, {
    Owner = var.owner_tag
  })
}
