﻿package {
    import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	import Shared.AS3.*;
	import flash.text.*;
	import flash.sampler.Sample;
	
	public class SliderList extends BSUIComponent
	{
		public var entries:Vector.<SliderListEntry> = new Vector.<SliderListEntry>(15);
		public var listScroll:Option_Scrollbar_Vertical;
		public var title:TextField;
		
		public var entrySize:int = 57;
		public var listSize:int = 10;
		public var stepSize:Number;
		public var listPosition: int = 0;
		
		public static const SLIDER_MAX:int = 10;
		public static const LIST_MAX:int = 15;
		
		public static const LIST = 0;
		public static const TRANSFORM = 1;
		public static const MORPH = 2;
		public static const CHECKBOX = 3;
		public static const EYES = 4;
		public static const ADJUSTMENT = 5;
		public static const ADJUSTMENTEDIT = 6;
		public static const POSITIONING = 7;
		
		public var type:int;
		
		public function SliderList() {
			super();
			addSliders(); 
			
			listScroll.minimum = 0;
			listScroll.maximum = 100;
			listScroll.StepSize = 1;
			listScroll.addEventListener(Option_Scrollbar.VALUE_CHANGE, onValueChange);
			updateScroll(Data.MAIN_MENU.length, LIST_MAX);
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		public function addSliders() {
			var entry:SliderListEntry;
			for(var i:int = 0; i < LIST_MAX; i++) 
			{
				entry = new SliderListEntry();
				this.addChild(entry);
				entries[i] = entry;
			}
		}

		public function onValueChange(event:flash.events.Event)
		{
			var newPosition:int = int(event.target.value / stepSize);
			newPosition = Math.max(0,Math.min(entrySize - listSize, newPosition));
			updatePosition(newPosition);
		}
		
		public function onMouseWheel(event:flash.events.Event)
		{
			if (listScroll.visible) {
				var newPosition:int = listPosition - int(event.delta);
				newPosition = Math.max(0,Math.min(entrySize - listSize, newPosition));
				if (updatePosition(newPosition)) {
					listScroll.position = stepSize * newPosition;
				}
			}
		}
		
		public function updatePosition(newPosition:int):Boolean
		{
			if (listPosition != newPosition) {
				var dif:int = newPosition - listPosition;
				listPosition = newPosition;
				for (var i:int = 0; i < listSize; i++) 
				{
					entries[i].id = listPosition + i;
					updateType(entries[i]);
				}
				Util.unselectText();
				//Util.playFocus();
				return true;
			}
			return false;
		}

		public function updateValues():void
		{
			if (type == LIST) return;
			for(var i:int = 0; i < listSize; i++) 
			{
				if (entries[i].visible) {
					entries[i].updateValue(true);
				}
			}
		}
		
		public function updateScroll(entrySize:int, listSize:int):void
		{
			this.entrySize = entrySize;
			this.listSize = listSize;
			
			listPosition = Math.max(0,Math.min(entrySize - listSize, listPosition));
			
			if (this.entrySize > this.listSize)
			{
				stepSize = 100.0 / (this.entrySize - this.listSize);
				var thumbHeight:Number = listScroll.Track_mc.height *  this.listSize / this.entrySize;
				listScroll.Thumb_mc.height = Math.max(thumbHeight, 40);
				listScroll.visible = true;
				//listScroll.position = 0;
				listScroll.updateHeight();
			}
			else
			{
				listScroll.visible = false;
			}
		}
		
		public function update(entrySize:int, listSize:int, func:Function, func2 = null, func3 = null)
		{
			updateScroll(entrySize, listSize);

			var length:int = Math.min(entrySize, listSize);
			for(var i:int = 0; i < LIST_MAX; i++) 
			{
				if (i < length) {
					entries[i].update(i + listPosition, func, func2, func3);
					updateType(entries[i]);
				} else {
					entries[i].disable();
				}
			}
			
			updateLayout();
		}
		
		public function updateLayout():void
		{
			var xOffset:int;
			var yOffset:int;
			
			switch (entries[i].type) //init
			{
				case SliderListEntry.DIVIDER:
				case SliderListEntry.SLIDER:
					xOffset = 18;
					yOffset = 10;
					break;
				default:
					xOffset = 12;
					yOffset = 10;
			}
			
			for (var i:int = 0; i < LIST_MAX; i++)
			{
				if (entries[i].visible) {

					switch (entries[i].type) { //pre set pos
						case SliderListEntry.DIVIDER:
						case SliderListEntry.SLIDER:
							xOffset = 18;
							break;
						default:
							xOffset = 12;
					}
					
					entries[i].setPos(xOffset, yOffset);
					
					switch (entries[i].type) { //post set pos
						case SliderListEntry.DIVIDER:
						case SliderListEntry.SLIDER:
							yOffset += 55;
							break;
						default:
							yOffset += 36;
					}
				}
			}
		}
		
		public function updateType(entry:SliderListEntry):void
		{
			switch (type) {
				case LIST: updateListEntry(entry); break;
				case TRANSFORM: updateTransformEntry(entry); break;
				case MORPH: updateMorphsEntry(entry); break;
				case CHECKBOX: updateCheckboxEntry(entry); break;
				case EYES: updateEyesEntry(entry); break;
				case ADJUSTMENT: updateAdjustmentEntry(entry); break;
				case ADJUSTMENTEDIT: updateAdjustmentEditEntry(entry); break;
				case POSITIONING: updatePositioningEntry(entry); break;
			}
		}
		
		public function updateList(func:Function):void
		{
			this.type = LIST;
			update(Data.menuOptions.length, LIST_MAX, func);
		}
		
		public function updateListEntry(entry:SliderListEntry):void
		{
			entry.updateList(Data.menuOptions[entry.id]);
		}
		
		public function updateCheckboxes(func:Function):void
		{
			this.type = CHECKBOX;
			update(Data.menuOptions.length, LIST_MAX, func);
		}
		
		public function updateCheckboxEntry(entry:SliderListEntry):void
		{
			entry.updateCheckbox(Data.menuOptions[entry.id], Data.menuValues[entry.id]);
		}
		
		public function updateAdjustment(func:Function, func2:Function, func3:Function)
		{
			this.type = ADJUSTMENT;
			update(Data.menuOptions.length, LIST_MAX, func, func2, func3);
		}
		
		public function updateAdjustmentEntry(entry:SliderListEntry)
		{
			entry.updateAdjustment(Data.menuOptions[entry.id]);
		}
		
		public function updateAdjustmentEdit(func:Function)
		{
			this.type = ADJUSTMENTEDIT;
			update(Data.menuValues.length, LIST_MAX, func);
		}
		
		public function updateAdjustmentEditEntry(entry:SliderListEntry)
		{
			switch (entry.id)
			{
				case 0: //Scale
					entry.updateSliderData(0, 100, 1, 0)
					entry.updateSlider("$SAM_Scale", SliderListEntry.INT);
					break;
				case 1: //Reset
					entry.updateList("$SAM_ResetAdjustment");
					break;
				case 2: //Save
					entry.updateList("$SAM_SaveAdjustment");
					break;
				case 3: //Persistent
					entry.updateCheckbox("$SAM_Saved", Data.menuValues[entry.id]);
					break;
				default:
					entry.updateList("Negate " + Data.menuValues[entry.id]);
			}
		}
		
		public function updateTransform(func:Function):void
		{
			this.type = TRANSFORM;
			update(Data.TRANSFORM_NAMES.length, SLIDER_MAX, func);
		}
	
		public function updateTransformEntry(entry:SliderListEntry)
		{
			if (entry.id < 3) //rot
			{
				entry.updateSliderData(0.0, 360.0, 0.1, 180.0, 2);
				entry.updateSlider(Data.TRANSFORM_NAMES[entry.id], SliderListEntry.FLOAT);
			}
			else if (entry.id < 6) //pos
			{
				entry.updateSliderData(0.0, 20.0, 0.01, 10.0, 4);
				entry.updateSlider(Data.TRANSFORM_NAMES[entry.id], SliderListEntry.FLOAT);
			}
			else if (entry.id < 7)//scale
			{
				entry.updateSliderData(0.0, 2.0, 0.01, 0.0, 4);
				entry.updateSlider(Data.TRANSFORM_NAMES[entry.id], SliderListEntry.FLOAT);
			}
			else if (entry.id < 10)//rot2
			{
				entry.updateDrag(Data.TRANSFORM_NAMES[entry.id])
			}
		}
		
		public function updateMorphs(func:Function):void
		{
			this.type = MORPH;
			update(Data.menuOptions.length, SLIDER_MAX, func);
		}
		
		public function updateMorphsEntry(entry:SliderListEntry):void
		{
			entry.updateSliderData(0, 100, 1, 0);
			entry.updateSlider(Data.menuOptions[entry.id], SliderListEntry.INT);
		}
		
		public function updateEyes(func:Function):void
		{
			this.type = EYES;
			update(Data.EYE_NAMES.length, SLIDER_MAX, func);
		}
		
		public function updateEyesEntry(entry:SliderListEntry):void
		{
			if (entry.id < 2) {
				entry.updateSliderData(0.0, 2.0, 0.01, 1.0, 4);
				entry.updateSlider(Data.EYE_NAMES[entry.id], SliderListEntry.FLOAT);
			}
			else {
				entry.updateCheckbox(Data.EYE_NAMES[entry.id], Data.menuValues[entry.id]);
			}
		}
		
		public function updatePositioning(func:Function):void
		{
			this.type = POSITIONING;
			update(Data.POSITIONING_NAMES.length, LIST_MAX, func);
		}
		
		public function updatePositioningEntry(entry:SliderListEntry):void
		{
			if (entry.id < 1) {
				entry.updateSliderData(0, 500, 1, 0, 0);
				entry.updateSlider(Data.POSITIONING_NAMES[entry.id], SliderListEntry.INT);
			}
			else if (entry.id < 8) {
				entry.updateDragValue(Data.POSITIONING_NAMES[entry.id]);
			}
			else {
				entry.updateList(Data.POSITIONING_NAMES[entry.id]);
			}
		}
	}
}