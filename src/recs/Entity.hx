package recs;

class Entity {
	public final components:Map<String, Component> = [];

	static var nextId:Int = 0;

	public final id:Int;

	public final tags:Array<String>;

	@:allow(recs)
	private var cmpChange:Entity->Void;

	public function new(?tags:Array<String>) {
		id = nextId++;
		this.tags = tags ?? [];
	}

	public function matches(comps:Array<Class<Component>>) {
		for (cmp in comps) {
			if (!has(cmp))
				return false;
		}

		return true;
	}

	public function add(cmp:Component) {
		final strId = Type.getClassName(Type.getClass(cmp));
		components[strId] = cmp;

		if (cmpChange != null)
			cmpChange(this);

		return this;
	}

	public function remove(cmp:Component) {
		final strId = Type.getClassName(Type.getClass(cmp));
		components.remove(strId);

		if (cmpChange != null)
			cmpChange(this);

		return this;
	}

	public function get<T:Component>(cmpcls:Class<T>):T {
		final strId = Type.getClassName(cmpcls);
		return cast components[strId];
	}

	public function has(cmpcls:Class<Component>):Bool {
		return components.exists(Type.getClassName(cmpcls));
	}
}
