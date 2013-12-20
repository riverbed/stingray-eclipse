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

package com.zeus.eclipsePlugin.model;

/**
 * Represents a JavaExtension
 * SFT: Implement this one day, perhaps when we can upload via SOAP
 */
public abstract class JavaExtension extends ModelElement
{

   /* Override */
   public Type getModelType()
   {      
      return Type.JAVA_EXTENSION;
   }
  

}
