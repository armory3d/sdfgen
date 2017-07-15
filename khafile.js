let project = new Project('sdfgen');

project.addSources('Sources');
project.addShaders('Shaders');
project.addLibrary('iron');
project.addAssets('Assets/**');
project.addDefine('arm_json');

resolve(project);
