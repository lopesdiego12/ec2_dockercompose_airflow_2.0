resource "aws_instance" "instance" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.medium"

  tags = {
        Name = "airflow"
    }

  key_name               = "diego"
  vpc_security_group_ids = [aws_security_group.acesso-ssh-airflow.id,
                            aws_security_group.acesso-externo-airflow.id]
  user_data              = data.template_file.user_data.rendered
  
}