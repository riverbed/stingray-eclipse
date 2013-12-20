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

package com.zeus.eclipsePlugin.model.soap;

/**
 * Interface that allows the SOAPUpdater class to update a SOAP ModelElements
 * internal details.
 */
public interface SOAPUpdatable
{   
   /**
    * This function synchronises the SOAP object with the server. At the end it 
    * should re-add itself to the Updater list list.
    * @return Returns false if this item should be deleted from the update queue.
    */
   public boolean updateFromZXTM();
   
  
   /**
    * Get the priority of this SOAP object, higher means it will be refreshed 
    * more often. The priority value should be about 20 - 100;
    * 
    * @return The priority of this SOAP object.
    */
   public int getPriority();
   
}
