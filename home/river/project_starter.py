import pathlib
import sys
import os

FILEPATH = pathlib.Path(__file__).parent


def gen_txt():
    projects_list = open(FILEPATH / "projects.txt", "a")
    projects_name = open(FILEPATH / "names.txt", "a")
    for path in [
        pathlib.Path("/home/saegl/projects/"),
        pathlib.Path("/home/saegl/shared/"),
    ]:
        for folder in path.rglob("*.git"):
            project_dir = folder.parent
            if "." not in str(project_dir):
                name = project_dir.parent.name + " : " + project_dir.name
                print(project_dir, file=projects_list)
                print(name, file=projects_name)

    projects_list.close()
    projects_name.close()


def open_project():
    projects_list = open(FILEPATH / "projects.txt", "r")
    projects_name = open(FILEPATH / "names.txt", "r")

    projects = dict(zip(projects_name, projects_list))
    project_name = os.popen("cat names.txt | fuzzel --dmenu").read()
    if not project_name:
        return

    project_path = projects[project_name]

    spawn_cmd = (
        f'foot -D {project_path[:-1]} direnv exec . nvim -c "Telescope find_files"'
    )

    os.system(f"riverctl spawn '{spawn_cmd}'")


if __name__ == "__main__":
    if "gen" in sys.argv:
        gen_txt()

    else:
        open_project()
