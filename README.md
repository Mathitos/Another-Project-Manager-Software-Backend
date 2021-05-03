# APMS - Another Project Management Software

This project is intended to be an app to manage taks, with signin, signup, projects by each user, and ordered tasks for each project


### How to Run
```sh
docker-compose up -d
mix setup
mix phx.start
```

### Routes
|Action|Need Authentication?|Method|Url|Body|Response|
|-----|--------------------|------|---|----|--------|
|SignUp|[]|POST|/api/v1/sign_up|{"email": email, "password": password}| {"id": user_id, "email": user_email} |
|SignIn|[]|POST|/api/v1/sign_in|{"email": email, "password": password}|{"jwt": jwt}|
|List Projects|[x]|GET|/api/v1/project/| - | [{"id": project_id, "name": project_name}] |
|Get Project|[x]|GET|/api/v1/project/{project_id}| - | {"id": project_id, "name": project_name} |
|Create Project|[x]|POST|/api/v1/project/|{"name": project_name}|{"id": project_id, "name": project_name}|
|Update Project|[x]|PUT|/api/v1/project/{project_id}|{value_key: value _to_update}|{"id": project_id, "name": project_name}|
|Delete Project|[x]|DELETE|/api/v1/project/{project_id}| - | - |
|List Tasks|[x]|GET|/api/v1/project/{project_id}/task| - | [{"id": task_id, "name": task_name, "description": task_description, "order": task_order}] |
|Get Task|[x]|GET|/api/v1/project/{project_id}/task/{task_id}| - | {"id": task_id, "name": task_name, "description": task_description, "order": task_order} |
|Create Task|[x]|POST|/api/v1/project/{project_id}/task|{"name": task_name, "description": task_description}|{"id": task_id, "name": task_name, "description": task_description, "order": task_order}|
|Update Task|[x]|PUT|/api/v1/project/{project_id}/task/{task_id}|{value_key: value _to_update}|{"id": task_id, "name": task_name, "description": task_description, "order": task_order}|
|Delete Task|[x]|DELETE|/api/v1/project/{project_id}/task/{task_id}| - | - |


### Adicional Notes
- authenticated routes needs to provide the bearer token on the authorization header, the bearer token can be obtained on SignIn action
- you can only see projects that your user created, and tasks in projects that you can see
- task order can't be lower than 1, or bigger than the bigest order on that project
- new tasks will always be created with order equals to biggest order on that project +1
- changing order on a task will rearange tasks for the same project accordingly
