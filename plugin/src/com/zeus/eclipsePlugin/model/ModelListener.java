/*******************************************************************************
 * Copyright (C) 2013 Riverbed Technology, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Riverbed Technology - Main Implementation
 ******************************************************************************/

package com.zeus.eclipsePlugin.model;

/**
 * Interface that should be implemented by anything wanting to be informed of
 * model changes.
 * 
 * IMPORTANT: Implementing classes should not perform any long term operations,
 * or anything that has to wait for user interaction in the implemented 
 * functions.
 */
public interface ModelListener
{
   /**
    * An element this listener is listening to has been changed in some way.
    * @param element The element that has been changed.
    * @param event The event that has happened
    */
   public void modelUpdated( ModelElement element, ModelElement.Event event );
   
   /**
    * The listened to element has had a child added to it.
    * @param parent The parent of the new child
    * @param child The new child object
    */
   public void childAdded( ModelElement parent, ModelElement child );
   
   /**
    * The elements current state has been altered in some way.
    * @param element The element that has changed
    * @param state The new state
    */
   public void stateChanged( ModelElement element, ModelElement.State state );
   
}
