# Folders
out = out
diff_folder_prefix = rohdef-
diff_old = ${diff_folder_prefix}diff-old
diff_result = ${diff_folder_prefix}diff
work_dir = .

# File names
thesis = thesis
thesis_file = ${thesis}.tex
refs_file = refs.bib
diff = diff

BRANCH=master
NON_TEX_FILES = $(filter-out %.tex,$(wildcard *))
TEX_FILES = $(filter %.tex,$(wildcard *))
OLD_TEX_FILES = $(filter ../${diff_old}/%.tex,$(wildcard *))

latex-diff-clean:
	-rm -rf ../${diff_result}
	-rm -rf ../${diff_old}
	-rm -rf ${diff}-${out}
	-rm -rf ${diff_file}

clean: latex-diff-clean
	-rm -rf ${out}

thesis:
	cd ${work_dir}; \
		mkdir ${out}; \
		rm ${out}/${refs_file}; \
		pdflatex --output-directory=${out} ${thesis_file}; \
		cp ${refs_file} ${out}/; \
		biber --output-directory=${out} ${thesis}; \
		pdflatex --output-directory=${out} ${thesis_file}; \
		pdflatex --output-directory=${out} ${thesis_file}
	mv ${work_dir}/${out} .

latex-diff-git: latex-diff-clean
# Setup the git details
	git clone . ../${diff_old}
	cd ../${diff_old}; \
		git checkout ${BRANCH}

latex-diff-setup: latex-diff-git
	mkdir -p ../${diff_result}
	for FILE in ${NON_TEX_FILES}; do cp $$FILE ../${diff_result} ; done

	for FILE in ${TEX_FILES} ; do \
		if [ ! -f ../${diff_old}/$$FILE ]; then \
			echo "Inserting missing file $$FILE"; \
			touch ../${diff_old}/$$FILE; \
		fi ; \
	done

latex-diff-execute: latex-diff-setup
# Latex diff
	for FILE in ${TEX_FILES}; do \
		latexdiff ../${diff_old}/$$FILE $$FILE > ../${diff_result}/$$FILE; \
	done

latex-diff-compile-setup: latex-diff-execute
	$(eval work_dir := ../${diff_result}/)
	$(eval out := ${diff}-${out})

latex-diff-temp-clean:
	-rm -rf ../${diff_old}
	-rm -rf ../${diff_result}

thesis-diff: latex-diff-compile-setup thesis latex-diff-temp-clean
