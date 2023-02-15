from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner

@task
def first_task(num):
    return num + num

@task
def second_task(num):
    return num * num

@flow(name="My Example Flow", 
      task_runner=SequentialTaskRunner(),
)
def my_flow(num):
    plusnum = first_task.submit(num)
    sqnum = second_task.submit(plusnum)
    print(f"add: {plusnum.result()}, square: {sqnum.result()}")

my_flow(5)