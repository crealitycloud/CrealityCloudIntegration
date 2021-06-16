import os
from shutil import copytree, ignore_patterns

def clear(filepath):
    files = os.listdir(filepath)
    for fd in files:
        cur_path = os.path.join(filepath, fd)
        if os.path.isdir(cur_path):
            if fd == "__pycache__":
                print("rm %s -rf" % cur_path)
                os.system("rm %s -rf" % cur_path)
            else:
                clear(cur_path)

def package():
    path = "./output/CrealityCloudIntegrationv101a"
    # isExists = os.path.exists(path)
    # if not isExists:
    #     os.makedirs(path)
    copytree("./", path+"/",
             ignore=ignore_patterns('*.jsc', '*.qmlc', '*.gitignore', '*.git', "build.py"))
    

if __name__ == "__main__":
    os.system("rm -rf *.jsc")
    os.system("rm -rf *.qmlc")
    os.system("rm -rf output")
    clear("./")
    package()
