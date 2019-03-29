/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package uiwidgets {
import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.*;
import util.Color;

public class Button extends Sprite {

	private var labelOrIcon:DisplayObject;
	private var color:* = CSS.titleBarColors;
	private var minWidth:int = 50;
	private var paddingX:Number = 5.5;
	private var compact:Boolean;

	private var action:Function; // takes no arguments
	private var eventAction:Function; // like action, but takes the event as an argument
	private var tipName:String;
	
	private var curTarget:Number = 0;
	private var target:Number = 0;

	public function Button(label:String, action:Function = null, compact:Boolean = false, tipName:String = null) {
		this.action = action;
		this.compact = compact;
		this.tipName = tipName;
		addLabel(label);
		mouseChildren = false;
		addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		addEventListener(Event.ENTER_FRAME, updateColor);
		setColor(CSS.titleBarColors);
	}
	
	private function updateColor(e:Event):void 
	{
		if (curTarget < target)
		{
			curTarget += 0.1;
			setColor(Color.mixRGB(CSS.white, CSS.overColor, curTarget));
		}else if (curTarget > target)
		{
			curTarget -= 0.1;
			setColor(Color.mixRGB(CSS.white, CSS.overColor, curTarget));
		}else {
			e.currentTarget.removeEventListener(Event.ENTER_FRAME, updateColor);
		}
		
	}

	public function setLabel(s:String):void {
		if (labelOrIcon is TextField) {
			TextField(labelOrIcon).text = s;
			setMinWidthHeight(0, 0);
		} else {
			if ((labelOrIcon != null) && (labelOrIcon.parent != null)) labelOrIcon.parent.removeChild(labelOrIcon);
			addLabel(s);
		}
	}

	public function setIcon(icon:DisplayObject):void {
		if ((labelOrIcon != null) && (labelOrIcon.parent != null)) {
			labelOrIcon.parent.removeChild(labelOrIcon);
		}
		labelOrIcon = icon;
		if (icon != null) addChild(labelOrIcon);
		setMinWidthHeight(0, 0);
	}

    public function setWidth(val:int):void{
        paddingX = (val - labelOrIcon.width)/2;
        setMinWidthHeight(5, 5);
    }

	public function setMinWidthHeight(minW:int, minH:int):void {
		if (labelOrIcon != null) {
			if (labelOrIcon is TextField) {
				minW = Math.max(minWidth, labelOrIcon.width + paddingX * 2);
				minH = compact ? 20 : 25;
			} else {
				minW = Math.max(minWidth, labelOrIcon.width + 12);
				minH = Math.max(minH, labelOrIcon.height + 11);
			}
			labelOrIcon.x = ((minW - labelOrIcon.width) / 2);
			labelOrIcon.y = ((minH - labelOrIcon.height) / 2);
		}
		// outline
		graphics.clear();
		graphics.lineStyle(1, CSS.borderColor, 1, true);
		if (color is Array) {
			var matr:Matrix = new Matrix();
			matr.createGradientBox(minW, minH, Math.PI / 2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, CSS.titleBarColors, [100, 100], [0x00, 0xFF], matr);
		}
		else graphics.beginFill(color);
		graphics.drawRect(0, 0, minW, minH);
		//graphics.drawRoundRect(0, 0, minW, minH, 10);
		graphics.endFill();
	}

	public function setEventAction(newEventAction:Function):Function {
		var oldEventAction:Function = eventAction;
		eventAction = newEventAction;
		return oldEventAction;
	}

	private function mouseOver(evt:MouseEvent):void {
		//setColor(CSS.overColor)
		target = 1;
		evt.currentTarget.addEventListener(Event.ENTER_FRAME, updateColor);
	}

	private function mouseOut(evt:MouseEvent):void {
		//setColor(CSS.titleBarColors)
		target = 0;
		evt.currentTarget.addEventListener(Event.ENTER_FRAME, updateColor);
	}

	private function mouseDown(evt:MouseEvent):void {
		Menu.removeMenusFrom(stage)
	}

	private function mouseUp(evt:MouseEvent):void {
		if (action != null) action();
		if (eventAction != null) eventAction(evt);
		evt.stopImmediatePropagation();
	}

	public function handleTool(tool:String, evt:MouseEvent):void {
		if (tool == 'help' && tipName) Scratch.app.showTip(tipName);
	}

	private function setColor(c:*):void {
		color = c;
		if (labelOrIcon is TextField) {
			(labelOrIcon as TextField).textColor = Color.mixRGB(CSS.buttonLabelColor, CSS.white, curTarget);//(c == CSS.overColor) ? CSS.white : CSS.buttonLabelColor;
		}
		setMinWidthHeight(5, 5);
	}

	private function addLabel(s:String):void {
		var label:TextField = new TextField();
		label.autoSize = TextFieldAutoSize.LEFT;
		label.selectable = false;
		label.background = false;
		//label.embedFonts = true;
		label.defaultTextFormat = CSS.normalTextFormat;
		label.textColor = CSS.buttonLabelColor;
		label.text = s;
		labelOrIcon = label;
		setMinWidthHeight(0, 0);
		addChild(label);
	}

}
}