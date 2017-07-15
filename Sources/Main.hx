package;

class Main {

	static var meshtex:kha.Image;
	static var numverts = 0;

	public static function main() {
		kha.System.init({title: "Empty", width: 640, height: 480}, function() {
			iron.App.init(ready);
		});
	}

	static function ready() {
		trace("SDF: Make tex");
		iron.Scene.setActive("Scene");
		
		var path = "mesh.obj";
		#if kha_kore
		path = Sys.getCwd() + "/" + path;
		#end

		iron.data.Data.getBlob(path, function(md:kha.Blob) {
			var obj = new ObjLoader(md.toString());
			var pa = obj.indexedVertices;
			var ia = obj.indices;

		// iron.data.Data.getMesh("mesh", "", null, function(md:iron.data.MeshData) {
			// var pa = md.geom.positions;
			// var ia = md.geom.indices[0]; // No multi-mat

			numverts = ia.length;

			var stride = 16384;
			var w = Std.int(Math.min(numverts, stride));
			var h = Std.int(numverts / stride) + 1;

			var o = new haxe.io.BytesOutput();

			for (i in 0...numverts) {
				o.writeFloat(pa[ia[i] * 3]);
				o.writeFloat(pa[ia[i] * 3 + 1]);
				o.writeFloat(pa[ia[i] * 3 + 2]);
				o.writeFloat(0.0);
			}
			// Finish line
			for (i in numverts...w * h * 4) {
				o.writeFloat(0.0);
			}

			meshtex = kha.Image.fromBytes(o.getBytes(), w, h, kha.graphics4.TextureFormat.RGBA64, kha.graphics4.Usage.StaticUsage);

			iron.object.Uniforms.externalTextureLinks = [externalTextureLink];
			iron.object.Uniforms.externalIntLinks = [externalIntLink];
		});
	}

	static function externalTextureLink(tulink:String):kha.Image {
		if (tulink == "_meshtex") {
			return meshtex;
		}
		return null;
	}

	static function externalIntLink(clink:String):Int {
		if (clink == "_meshverts") {
			return numverts;
		}
		return 0;
	}

	static var startTime = 0.0;
	public static function begin() {
		trace("SDF: GPU");
		startTime = kha.Scheduler.realTime();
	}

	public static function end() {
		trace("SDF: " + Std.int((kha.Scheduler.realTime() - startTime) * 10000) / 10 + "ms processing " + numverts + " vertices");
		trace("SDF: Write");
		var image = iron.Scene.active.camera.data.pathdata.renderTargets.get("sdf").image;
		var b = image.getPixels();

		#if kha_krom
		Krom.fileSaveBytes("out.bin", b.getData());
		#else
		sys.io.File.saveBytes("out.bin", b);
		#end

		trace("SDF: Done");
		kha.System.requestShutdown();
	}
}
