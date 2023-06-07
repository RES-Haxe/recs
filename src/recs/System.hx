package recs;

import res.display.FrameBuffer;

abstract class System {
	final components:Array<Class<Component>>;

	final entities:Array<Entity> = [];

	public var useUpdate:Bool = false;
	public var useRender:Bool = false;

	@:allow(recs)
	var engine:Engine;

	public function new(components:Array<Class<Component>>) {
		this.components = components;
	}

	/**
		Check if the given Entity should be governed by this systems or not.
		If it is - add to (or keep in) this system
		Otherwise remove it (if already added)

		@param  entity
						Entity that should or should not belong to this system
	 */
	public function suggestBelong(entity:Entity) {
		if (entity.matches(components)) {
			if (entities.indexOf(entity) == -1)
				entities.push(entity);
		} else {
			entities.remove(entity);
		}
	}

	public function removeEntity(entity:Entity) {
		entities.remove(entity);
	}

	function matches(entity:Entity) {
		return entity.matches(components);
	}

	public function update(dt:Float) {
		for (entity in entities) {
			updateEntity(entity, dt);
		}
	}

	public function render(fb:FrameBuffer) {
		for (entity in entities) {
			renderEntity(entity, fb);
		}
	}

	public function updateEntity(entity:Entity, dt:Float):Void {}

	public function renderEntity(entity:Entity, fb:FrameBuffer):Void {}
}
