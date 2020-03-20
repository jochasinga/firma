project_name = api_server

opam_file = $(project_Name).opam

.PHONY: deps run run-debug

# Alis to update the opam file and install the needed deps
deps: $(opam_file)

build:
	dune build $(project_name).exe

# Build and run the app
run:
	dune exec ./$(project_name).exe

# Build and run the app with Opium's internal debug messages visible
run-debug:
	dune exec $(project_name) -- --debug

# Update the package dependencies when new deps are added to dune-project
$(opam_file): dune-project
	-dune build @install        # Update the $(project_name).opam file
	-git add $(opam_file)       # opam uses the state of master for it updates
	-git commit $(opam_file) -m "Updating package dependencies"
	opam install . --deps-only  # Install the new dependencies
