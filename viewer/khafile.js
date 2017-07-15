let project = new Project('Viewer');

project.addSources('Sources');
project.addShaders('Shaders');
project.addLibrary('../../Libraries/iron');
project.addAssets('Assets/**');
project.addDefine('arm_json');

resolve(project);
