example01.png : example01.pdf
	pdftoppm -png -singlefile -scale-to-x 850 -scale-to-y -1 $< $(basename $@)

example01.pdf : example01.yml ../src/pdfschedule.py
	python3 -m pip-run -q .. -- -m pdfschedule $< $@
