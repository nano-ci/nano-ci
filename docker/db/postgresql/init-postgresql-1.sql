create role nano_ci
	login
	superuser
	password 'example';

create database nano_ci_development
	owner = nano_ci;
