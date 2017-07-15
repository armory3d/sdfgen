package;

class Main {

	static var sdftex:kha.Image;

	public static function main() {
		kha.System.init({title: "Empty", width: 640, height: 640}, function() {
			iron.App.init(ready);
		});
	}

	static function ready() {
		iron.Scene.setActive("Scene");
		iron.data.Data.getBlob("out.bin", function(blob:kha.Blob) {

			var res = 50;
			sdftex = kha.Image.fromBytes(blob.toBytes(), res * res, res, kha.graphics4.TextureFormat.A16, kha.graphics4.Usage.StaticUsage);

			iron.object.Uniforms.externalTextureLinks = [externalTextureLink];
		});
	}

	static function externalTextureLink(tulink:String):kha.Image {
		if (tulink == "_sdftex") {
			return sdftex;
		}
		return null;
	}
}
