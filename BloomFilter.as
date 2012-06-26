package
{
	import flash.utils.ByteArray;
	
	public class BloomFilter
	{
		private var m:uint;
		private var k:uint;
		private var buckets:Array;
		private var _locations:Array;
		
		public function BloomFilter(m:uint, k:uint)
		{
			this.m = m;
			this.k = k;
			var n:uint = Math.ceil(m / 32);
			this.buckets = new Array();
			this._locations = new Array()
			var i:int = -1;
			while (++i < n) this.buckets[i] = 0;
		}
		
		public function add(v:ByteArray):void {
			var l:Array = locations(v);
			var	i:int = -1;
			while (++i < this.k) this.buckets[Math.floor(l[i] / 32)] |= 1 << (l[i] %   32);
		}
		
		public function test(v:ByteArray):Boolean {
			var l:Array = locations(v),
				i:int = -1,
				b:int;
			while (++i < this.k) {
				b = l[i];
				if ((this.buckets[Math.floor(b / 32)] & (1 << (b % 32))) === 0) {
					return false;
				}
			}
			return true;
		}
		
		protected function locations(v:ByteArray):Array {
			var r:Array = this._locations,
				a:int = fnv_1a(v),
				b:int = fnv_1a_b(a),
				i:int = -1,
				x:int = a % this.m;
			
			while (++i < this.k) {
				r[i] = x < 0 ? (x + this.m) : x;
				x = (x + b) % this.m;
			}
			return r;
		}
		
		protected function fnv_1a(v:ByteArray):uint {
			var n:uint = v.length,
				a:uint = 2166136261,
				c:uint,
				d:uint,
				i:int = -1;
			while (++i < n) {
				c = v[i];
				if (d = c & 0xff000000) {
					a ^= d >> 24;
					a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
				}
				if (d = c & 0xff0000) {
					a ^= d >> 16;
					a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
				}
				if (d = c & 0xff00) {
					a ^= d >> 8;
					a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
				}
				a ^= c & 0xff;
				a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
			}
			// From http://home.comcast.net/~bretm/hash/6.html
			a += a << 13;
			a ^= a >> 7;
			a += a << 3;
			a ^= a >> 17;
			a += a << 5;
			return a & 0xffffffff;
		}
		
		protected function fnv_1a_b(a:uint):uint {
			a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
			a += a << 13;
			a ^= a >> 7;
			a += a << 3;
			a ^= a >> 17;
			a += a << 5;
			return a & 0xffffffff;
		}
	}
}
