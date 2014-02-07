/*******************************************************************************
 * Copyright (C) 2014 Riverbed Technology, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * https://github.com/riverbed/stingray-eclipse/blob/master/LICENSE
 * This software is distributed "AS IS".
 *
 * Contributors:
 *     Riverbed Technology - Main Implementation
 ******************************************************************************/

package com.zeus.eclipsePlugin.filesystem;

import com.zeus.eclipsePlugin.model.ModelElement;
import com.zeus.eclipsePlugin.model.ModelElement.Event;

public interface FileSystemListener
{
   public void refreshingFromModelChange( ModelElement element, Event event );
}
