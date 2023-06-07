package recs;

import res.display.FrameBuffer;

class Engine {
	final entities:Array<Entity> = [];
	final systems:Array<System> = [];

	final tagged:Map<String, Array<Entity>> = [];

	final byComponent:Map<String, Array<Entity>> = [];

	public var numEntities(get, never):Int;

	inline function get_numEntities() {
		return entities.length;
	}

	public var numSystems(get, never):Int;

	function get_numSystems() {
		return systems.length;
	}

	public function new() {}

	function cmpChange(entity:Entity) {
		for (system in systems) {
			system.suggestBelong(entity);
		}
	}

	/**
		Get all the entities marked my the given tag
	**/
	public inline function getTagged(tag:String):Array<Entity> {
		return tagged.exists(tag) ? tagged[tag] : [];
	}

	public function addEntity(entity:Entity) {
		if (entities.indexOf(entity) != -1)
			return entity;

		entities.push(entity);

		entity.cmpChange = cmpChange;

		for (system in systems) {
			system.suggestBelong(entity);
		}

		for (tag in entity.tags) {
			if (!tagged.exists(tag))
				tagged[tag] = [];

			tagged[tag].push(entity);
		}

		for (compId => _ in entity.components) {
			byComponent[compId] = byComponent[compId] ?? [];
			byComponent[compId].push(entity);
		}

		return entity;
	}

	public function removeEntity(entity:Entity) {
		if (entities.indexOf(entity) == -1)
			return;

		entities.remove(entity);

		entity.cmpChange = null;

		for (system in systems) {
			system.removeEntity(entity);
		}

		for (tag in entity.tags)
			tagged[tag].remove(entity);

		for (compId => _ in entity.components) {
			if (byComponent.exists(compId))
				byComponent[compId].remove(entity);
		}
	}

	/**
		Final all the components with the given component
	 */
	public function query(component:Class<Component>):Array<Entity> {
		return byComponent[Type.getClassName(component)] ?? [];
	}

	/**
		Get all the entities that has all of the listed component
	 */
	public function queryAll(comps:Array<Class<Component>>):Array<Entity> {
		final result = [];

		for (entity in entities) {
			if (entity.matches(comps))
				result.push(entity);
		}

		return result;
	}

	public function addSystem(system:System) {
		system.engine = this;
		systems.push(system);
	}

	public function addSystems(systems:Array<System>) {
		for (item in systems)
			addSystem(item);
	}

	public function removeSystem(system:System) {
		if (systems.indexOf(system) == -1)
			return;

		system.engine = null;
		systems.remove(system);
	}

	public function update(dt:Float) {
		for (system in systems) {
			if (system.useUpdate)
				system.update(dt);
		}
	}

	public function render(fb:FrameBuffer) {
		for (system in systems) {
			if (system.useRender)
				system.render(fb);
		}
	}

	static function main() {}
}
