c = get_config()
c.NotebookApp.notebook_dir = u'ipynb/'           # Look for notebooks here
c.IPKernelApp.exec_lines = ["import os as _os",  # On notebook startup, change
                            "_os.chdir('..')"]   #+PWD to the project root.
c.IPKernelApp.matplotlib = 'inline'              # Display figures inline
