import subprocess
from os import path
import os
import shutil
from glob import glob
import typing
import sys
import platform
import random

# TODO:
# - Make this file never show it's call stack. Call stacks should mean that a child script failed.
# - Add self-documenting build.ini or similar, as to not require anyone to look
#		at this file unless they want to add a new backend.
# - It could be nice to be able to generate into another folder, or just say --copy-into../../my_cool_folder


# @CONFIGURE: Should be a valid dear imgui tag or hash.
# Note that if this is changed, that you will also have to acquire dear_bindings .json files for the same version:
# https://github.com/dearimgui/dear_bindings/releases
imgui_version = "v1.92.8-docking"

# Note - tested with Odin version `dev-2025-07`

# @CONFIGURE: Elements must be keys into below table
wanted_backends = ["sdl3", "sdlrenderer3"]

# Supported means that an impl bindings file exists, and that it has been tested.
# Some backends (like dx12, win32) have bindings but not been tested.
backends = {
	"sdl3":         { "supported": True,  "deps": ["sdl3"] },
	"sdlrenderer3": { "supported": True,  "deps": ["sdl3"] },
}

# Indirection for backend dependencies, as some might have the same dependency, and their commits can't get out of sync.
# NOTE[TS]: the versions used here should represent the version in odin:vendor.
backend_deps = {
	# NOTE[TS]: SDL2 renderer doesn't compile with this version, and is disabled for this reason.
	"sdl2":   { "repo": "https://github.com/libsdl-org/SDL.git",               "commit": "release-2.0.16", "path": "SDL2" },
	"sdl3":   { "repo": "https://github.com/libsdl-org/SDL.git",               "commit": "release-3.4.2",  "path": "SDL3" },
	"glfw":   { "repo": "https://github.com/glfw/glfw.git",                    "commit": "3.4",            "path": "glfw" },
	"vulkan": { "repo": "https://github.com/KhronosGroup/Vulkan-Headers.git",  "commit": "v1.4.309",       "path": "Vulkan-Headers" },
}

# @CONFIGURE:
compile_debug = False
# @CONFIGURE:
build_wasm = False

our_compiler = "cl"
if platform.system() != "Windows" or build_wasm:
	our_compiler = "clang"

# Assert which doesn't clutter the output
def assertx(cond: bool, msg: str):
	if not cond:
		print(msg)
		exit(1)

def hashes_are_same_ish(first: str, second: str) -> bool:
	smallest_hash_size = min(len(first), len(second))
	assertx(smallest_hash_size >= 7, "Hashes not long enough to be sure")
	return first[:smallest_hash_size] == second[:smallest_hash_size]

def exec(cmd: typing.List[str], what: str) -> str:
	max_what_len = 40
	if len(what) > max_what_len:
		what = what[:max_what_len - 2] + ".."
	print(what + (" " * (max_what_len - len(what))) + "> " + " ".join(cmd))
	try: return subprocess.check_output(cmd).decode('utf-8')
	except subprocess.CalledProcessError as uh_oh:
		print("=" * 80)
		print("FAILED")
		print("=" * 80)
		print(uh_oh.output.decode())
		exit(1)

def exec_vcvars(cmd: typing.List[str], what):
	max_what_len = 40
	if len(what) > max_what_len:
		what = what[:max_what_len - 2] + ".."
	print(what + (" " * (max_what_len - len(what))) + "> " + " ".join(cmd))
	assertx(subprocess.run(f"vcvarsall.bat x64 && {' '.join(cmd)}", shell=True).returncode == 0, f"Failed to run command '{cmd}'")

def copy(from_path: str, files: typing.List[str], to_path: str):
	for file in files:
		shutil.copy(path.join(from_path, file), to_path)

# glob copy backported for python 3.9
def glob_copy_39(root_dir: str, glob_pattern: str, dest_dir: str):
	real_pattern = os.path.join(root_dir, glob_pattern)
	the_files = glob(real_pattern)

	# strip root_dir
	results = []
	for item in the_files:
		results.append(item[len(root_dir)+1:])

	copy(root_dir, results, dest_dir)
	return results

def glob_copy(root_dir: str, glob_pattern: str, dest_dir: str):
	version_info = sys.version_info
	if version_info.major == 3 and version_info.minor == 9:
		return glob_copy_39(root_dir, glob_pattern, dest_dir)

	the_files = glob(root_dir=root_dir, pathname=glob_pattern)
	copy(root_dir, the_files, dest_dir)
	return the_files

def compiler_select(the_options) -> list[str]:
	""" Given a dict like eg. { "cl": "/DCOOL_DEFINE", "clang, gcc": "-DCOOL_DEFINE" }
	Returns the correct value for the active compiler. """
	for compilers_string in the_options:
		if compilers_string.lower().find(our_compiler) != -1:
			return the_options[compilers_string]

	print(the_options)
	assertx(False, f"Couldn't find active compiler ({our_compiler}) in the above options!")
	return []

def pp(the_path: str) -> str:
	""" Get Platform Path. Given a path with '/' as a delimiter, returns an appropriate sys.platform path """
	return path.join(*the_path.split("/"))

def map_to_folder(files: typing.List[str], folder: str) -> typing.List[str]:
	return list(map(lambda file: path.join(folder, file), files))

def has_tool(tool: str) -> bool:
	try: subprocess.check_output([tool], stderr=subprocess.DEVNULL)
	except FileNotFoundError: return False
	except: return True
	else: return True

def ensure_checked_out_with_commit(dir: str, repo: str, wanted_commit: str):
	if not path.exists(dir):
		exec(["git", "clone", "--depth=1", repo, "--branch", wanted_commit, dir], f"Cloning {dir}")

	exec(["git", "-c", "advice.detachedHead=false", "-C", dir, "checkout", "--force", wanted_commit], f"Checking out {dir}")

def get_platform_imgui_lib_name() -> str:
	""" Returns imgui binary name for system/processor """

	system = platform.system()

	processor = None
	if platform.machine() in ["AMD64", "x86_64"]:  processor = "x64"
	if platform.machine() in ["arm64", "aarch64"]: processor = "arm64"

	binary_ext = "lib" if system == "Windows" else "a"

	assertx(system != "", "System could not be determined")
	assertx(processor != None, f"Unexpected processor: {platform.machine()}")

	return f'imgui_{system.lower()}_{processor}.{binary_ext}'

def compile(backend_deps_names: typing.Set[str], all_sources: typing.List[str], wasm: bool):
	# Basic flags
	compile_flags = compiler_select({
		"cl": ["/DIMGUI_DISABLE_OBSOLETE_FUNCTIONS"],
		"clang": ["-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS"],
	})

	# We aren't meant to have IMGUI_IMPL_API be extern "C"?
	# https://github.com/ocornut/imgui/issues/7930#issuecomment-2319725332
	if wasm:
		compile_flags += ['-DIMGUI_IMPL_API=extern\"C\"', "-DIMGUI_DISABLE_DEFAULT_SHELL_FUNCTIONS", "-DIMGUI_DISABLE_FILE_FUNCTIONS", "--target=wasm32", "-mbulk-memory", "-fno-exceptions", "-fno-rtti", "-fno-threadsafe-statics", "-nostdlib++", "-fno-use-cxa-atexit"]

		assertx(has_tool("odin"), "odin not found!")
		root = exec(["odin", "root"], "Get odin root")
		compile_flags += ["--sysroot=" + root + "vendor/libc-shim"]
	else:
		compile_flags += compiler_select({
			"cl": ['/DIMGUI_IMPL_API=extern\\\"C\\\"'],
			"clang": ['-DIMGUI_IMPL_API=extern\"C\"', "-fPIC", "-fno-exceptions", "-fno-rtti", "-fno-threadsafe-statics", "-std=c++11"],
		})

	# Optimization flags
	if compile_debug: compile_flags += compiler_select({ "cl": ["/Od", "/Z7"], "clang": ["-g", "-O0"] })
	else: compile_flags += compiler_select({ "cl": ["/O2"], "clang": ["-O3"] })

	if not wasm:
		# Find and copy imgui backend sources to temp folder
		for backend_name in wanted_backends:
			backend = backends[backend_name]

			if "enabled_on" in backend and not platform.system().lower() in backend["enabled_on"]:
				continue

			if not backend["supported"]:
				print(f"Warning: compiling backend '{backend_name}' which is not officially supported")

			if "odin" in backend and backend["odin"]:
				print(f"Note: backend '{backend_name}' is native Odin code, nothing to compile")
				continue

			glob_copy(pp("imgui/backends"), f"imgui_impl_{backend_name}.*", "temp")

			if backend_name in ["osx", "metal"]: all_sources += [f"imgui_impl_{backend_name}.mm"]
			else:                                all_sources += [f"imgui_impl_{backend_name}.cpp"]

			if backend_name == "opengl3":
				shutil.copy(pp("imgui/backends/imgui_impl_opengl3_loader.h"), "temp")

			if backend_name == "sdlgpu3":
				shutil.copy(pp("imgui/backends/imgui_impl_sdlgpu3_shaders.h"), "temp")

			for define in backend.get("defines", []): compile_flags += [compiler_select({ "cl": f"/D{define}", "clang": f"-D{define}" })]

		# Add backend dependency include paths
		for backend_dep in backend_deps_names:
			include_path = path.join(backend_deps[backend_dep]["path"], "include")
			if "include" in backend_deps[backend_dep]:
				include_path = backend_deps[backend_dep]["include"]

			if our_compiler == "cl": compile_flags += ["/I" + path.join("..", "backend_deps", include_path)]
			else:                    compile_flags += ["-I" + path.join("..", "backend_deps", include_path)]

	all_objects = []
	if our_compiler == "cl": all_objects += map(lambda file: file.removesuffix(".cpp") + ".obj", all_sources)
	else:
		for file in all_sources:
			if file.endswith(".cpp"): all_objects.append(file.removesuffix(".cpp") + ".o")
			elif file.endswith(".mm"): all_objects.append(file.removesuffix(".mm") + ".o")

	os.chdir("temp")

	# cl.exe, *in particular*, won't work without running vcvarsall first, even if cl.exe is in the path.
	if our_compiler == "cl": exec_vcvars(["cl"] + compile_flags + ["/c"] + all_sources, "Compiling sources cl")
	else:                    exec(["clang"] + compile_flags + ["-c"] + all_sources, "Compiling sources clang")

	os.chdir("..")

	dest_binary = get_platform_imgui_lib_name()

	if wasm:
		shutil.rmtree(path="wasm", ignore_errors=True)
		os.mkdir("wasm")
		copy("temp", all_objects, "wasm")
	elif our_compiler == "cl": exec_vcvars(["lib", "/OUT:" + dest_binary] + map_to_folder(all_objects, "temp"), "Making library from objects")
	else:                      exec(["ar", "rcs", dest_binary] + map_to_folder(all_objects, "temp"), "Making library from objects")

def main():
	assertx(path.isfile("build.py"), "You have to run the script from within the repository for now!")

	# Check that CLI tools are available
	assertx(has_tool("git"), "Git not available!")

	if our_compiler != "cl":
		assertx(has_tool("clang"), "clang not found!")
		assertx(has_tool("ar"), "ar not found!")

	# Check out bindings generator tools
	ensure_checked_out_with_commit("imgui", "https://github.com/ocornut/imgui.git", imgui_version)

	# Check out backend dependencies
	if not path.isdir("backend_deps"): os.mkdir("backend_deps")
	backend_deps_names = set()
	for backend_name in wanted_backends:
		backend = backends[backend_name]

		for dep in backend.get("deps", []):
			backend_deps_names.add(dep)

	for backend_dep in backend_deps_names:
		full_dep = backend_deps[backend_dep]
		ensure_checked_out_with_commit(path.join("backend_deps", full_dep["path"]), full_dep["repo"], full_dep["commit"])

	# Clear the temp folder
	shutil.rmtree(path="temp", ignore_errors=True)
	os.mkdir("temp")

	# Generate odin bindings from dear_bindings json files
	exec([sys.executable, pp("gen_odin.py"), "--imgui", pp("dcimgui/dcimgui_nodefaultargfunctions.json"), "--imgui_internal", pp("dcimgui/dcimgui_nodefaultargfunctions_internal.json")], "Running odin-imgui")

	# We will be building up a list of files in the temp folder to compile.
	all_sources = []

	# Find and copy imgui sources to temp folder
	_imgui_headers = glob_copy("imgui", "*.h", "temp")
	imgui_sources = glob_copy("imgui", "*.cpp", "temp")
	all_sources += imgui_sources

	# Find and copy cimgui sources to temp folder
	_cimgui_headers = glob_copy("dcimgui", "*.h", "temp")
	cimgui_sources = glob_copy("dcimgui", "*.cpp", "temp")
	all_sources += cimgui_sources

	# Write file describing the build configuration.
	f = open("imgui_enabled.odin", "w+")
	f.writelines([
		"package imgui\n",
		"\n",
		"// This is a generated helper file which you can use to know about the build configuration.\n",
		"\n",
	])

	f.writelines([f"WASM_ENABLED :: {'true' if build_wasm else 'false'}", "\n", "\n"])

	for backend_name in backends:
		f.writelines([f"BACKEND_{backend_name.upper()}_ENABLED :: {'true' if backend_name in wanted_backends else 'false'}\n"])

	compile(backend_deps_names, all_sources, build_wasm)

	dest_binary = get_platform_imgui_lib_name()
	expected_files = ["imgui.odin", dest_binary]
	for file in expected_files:
		assertx(path.isfile(file), f"Missing file '{file}' in build folder! Something went wrong..")

	print("Looks like everything went ok!")
	if random.random() < 0.01: print("But looks may deceive..")

if __name__ == "__main__":
	main()
