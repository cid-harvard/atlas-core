SHELL=/bin/bash
SHELLOPTS=errexit:pipefail

ENVDIR=env
ACTIVATE:=$(ENVDIR)/bin/activate

.PHONY:	clean

count=10


PYTHON_EXECUTABLE=python3
VIRTUALENV_EXECUTABLE=pyvenv


requirements = requirements.txt requirements-dev.txt
virtualenv: $(ACTIVATE)
$(ACTIVATE): $(requirements)
	test -d $(ENVDIR) || $(VIRTUALENV_EXECUTABLE) $(ENVDIR)
	for f in $?; do \
		. $(ACTIVATE); pip install -r $$f; \
	done
	touch $(ACTIVATE)

dev: virtualenv
	. $(ACTIVATE); FLASK_CONFIG="../conf/dev.py" $(PYTHON_EXECUTABLE) runserver.py

test: virtualenv
	. $(ACTIVATE); FLASK_CONFIG="../conf/dev.py" py.test -v --cov atlas_core atlas_core/tests.py

testdebug: virtualenv
	. $(ACTIVATE); FLASK_CONFIG="../conf/dev.py" py.test -sv --pdb --pdbcls=IPython.core.debugger:Pdb --cov atlas_core atlas_core/tests.py

shell: virtualenv
	. $(ACTIVATE); FLASK_CONFIG="../conf/dev.py" $(PYTHON_EXECUTABLE) manage.py shell

dummy: virtualenv
	. $(ACTIVATE); FLASK_CONFIG="../conf/dev.py" $(PYTHON_EXECUTABLE) manage.py dummy -n $(count)

docs: virtualenv
	git submodule update --init
	. $(ACTIVATE); make -C doc/ html
	open doc/_build/html/index.html

clean:
	rm -rf $(ENVDIR)
	rm -rf doc/_build/
