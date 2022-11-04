init:
	terraform init

apply: *.tf
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

clean:
	@rm -rf .terraform* terraform*
