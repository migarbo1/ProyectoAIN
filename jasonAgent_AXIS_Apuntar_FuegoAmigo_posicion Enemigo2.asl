debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_SOLDIER").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(30).




{ include("jgomas.asl") }


// Plans


/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
//  GET AGENT TO AIM
/////////////////////////////////
/**
 * Calculates if there is an enemy at sight.
 *
 * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
 * Of View of the agent) looking for an enemy. If an enemy agent is found, a
 * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
 * enemy found. Otherwise, the return value is aimed("false")
 *
 * <em> It's very useful to overload this plan. </em>
 * 
 */
+!get_agent_to_aim
    <-
        ?fovObjects(FOVObjects);
        .length(FOVObjects, Length);
        
        if (Length > 0) {
            //DEBUG
            //.println("Veo este numero de objetos: ", Length, "     ", FOVObjects);
            //DEBUG
            +bucle(0);
            -+iaimed("false");
            while(iaimed("false") & bucle(X) & X < Length) { //MIENTRAS NO HAYA OBSERVADO TODOS LOS AGENTES Y NO ESTE A PUNTANDO A NADIE
				// Object structure 
                // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
                .nth(X, FOVObjects, Object);
                .nth(2, Object, Type);
                
                if (Type > 1000) {
                //NADA
                } else {//SI HA ENCONTRADO UN AGENTE
                    .nth(1, Object, Team);
          
                    if (Team == 100) {  // SI ENCUENTRA UN ENEMIGO
                        //DEBUG
                        //.println("He visto un enemigo");
                        //DEBUG
						+aimed_agent(Object);
						.nth(6, Object, PosE);//POSICION DEL ENEMIGO
						.nth(4, Object, DistE);// DISTANCIA DEL ENEMIGO
						-+iaimed("true");
                        
                        .my_team("AXIS", E1);
						.length(E1, L);
						if (L > 0) { //No estoy solo
							.concat("goto_kill(",PosE, ")", Content1);
							.send_msg_with_conversation_id(E1, tell, Content1, "INT");
						}
                        
						+bubucle(0);
                        //DEBUG
                        //.println("Entrando al bucle");
                        //DEBUG
						while(iaimed("true") & bubucle(J) & J < X) { // RECORRE LOS OBJETOS QUE ESTAN DELANTE DE EL
                            //DEBUG
                            //.println("Voy a comprobar mis alrededores   ", J);
                            //DEBUG
							.nth(J, FOVObjects, Objectt);
                            //.println("1     ", Objectt);
							.nth(2, Objectt, Typee);
                            //.println("2");
							if (Typee > 1000) {
							//NADA 
							} else{
								.nth(1, Objectt, Teamm);
                                //.println("3");
								.nth(4, Objectt, DistA);//DISTANCIA DEL ALIADO
                                //.println("4");
								.nth(6, Objectt, PosA);// POSICION DEL ALIADO
                                //.println("5");
								if (Teamm == 200){ // SI HAY UN ALIADO DELANTE
                                    //DEBUG
                                    //.println("He visto un aliado y puede que este delante");
                                    //DEBUG
									!distance(PosE , PosA);//DISTANCIA ENTRE A Y E
                                    ?distance( D );
                                    //.println( "La distancia entre los dos puntos es: ", D+DistA);
                                    //.println( "La distancia entre los dos puntos es: ", DistE);
									if((D+DistA) >= (DistE-5) & (D+DistA) <= (DistE+5)){//SI LA SUMA DE DISTANCIA ES PARECIDA A LA DISTANCIA ENTRE EL AGENTE Y EL ENEMIGO ESTA EN MEDIO DE LA LINEA DE FUEGO
										-+iaimed("false");
										.println("EVITANDO FUEGO AMIGO");
									}
								}
							}
							-+bubucle(J+1)
						}
						-bubucle(_);
                    }
                    
                }//ELSE
             
                -+bucle(X+1);
                
            }//WHILE
                     
        -bucle(_)
        }//IF
        if(iaimed("true")){
            -+aimed("true")
        }else{
            -+aimed("false")
        }
        //DEBUG
        //.println("FIN");
        //DEBUG
        .
/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ///?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
        };    
        -look_response(_)[source(M)];
        -+fovObjects(FOVObjects);
        //.//;
        !look.
      
        
/////////////////////////////////
//  PERFORM ACTIONS
/////////////////////////////////
/**
 * Action to do when agent has an enemy at sight.
 *
 * This plan is called when agent has looked and has found an enemy,
 * calculating (in agreement to the enemy position) the new direction where
 * is aiming.
 *
 *  It's very useful to overload this plan.
 * 
 */

+!perform_aim_action
    <-  // Aimed agents have the following format:
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        ?aimed_agent(AimedAgent);
        ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
        .nth(1, AimedAgent, AimedAgentTeam);
        ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam); }
        ?my_formattedTeam(MyTeam);


        if (AimedAgentTeam == 100) {

            .nth(6, AimedAgent, NewDestination);
            ?debug(Mode); if (Mode<=1) { .println("NUEVO DESTINO MARCADO: ", NewDestination); }
            .my_name(MyName);
            !distance(NewDestination);
            ?distance( D );
            !add_task(task(5000,"TASK_GOTO_POSITION",MyName,NewDestination,""));
			-+state(standing);
            if(D <= 5){
                .println("ESPERANDO");
                .wait(100);
            }
        }
        .
    
/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_look_action .
/// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_LOOK_ACTION GOES HERE.") }.

/**
 * Action to do if this agent cannot shoot.
 *
 * This plan is called when the agent try to shoot, but has no ammo. The
 * agent will spit enemies out. :-)
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_no_ammo_action .
/// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.

/**
 * Action to do when an agent is being shot.
 *
 * This plan is called every time this agent receives a messager from
 * agent Manager informing it is being shot.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_injury_action .
///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }.


/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/
+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 2000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",1000);
        +task_priority("TASK_ATTACK", 1000);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 750).   



/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////
/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets 
	<-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") }.
	
	
/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkMedicAction
<-  -+medicAction(on).
// go to help


/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////
/**
 * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkAmmoAction
<-  -+fieldopsAction(on).
//  go to help



/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////
/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction
       <-
       
       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }
       
       ?my_ammo_threshold(At);
       ?my_ammo(Ar);
       
       if (Ar <= At) { 
          ?my_position(X, Y, Z);
          
         .my_team("fieldops_AXIS", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");
       
       
       }
       
       ?my_health_threshold(Ht);
       ?my_health(Hr);
       
       if (Hr <= Ht) {  
          ?my_position(X, Y, Z);
          
         .my_team("medic_AXIS", E2);
         //.println("Mi equipo medico: ", E2 );
         .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
         .send_msg_with_conversation_id(E2, tell, Content2, "CFM");

       }
       .
       
/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////

   
    
+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.  

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.  

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.  

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.  

+goto_kill(P)[source(A)] : iaimed("false")
<-
    .println("Recibido mensaje goto de ", A, "     aimed = false");
    ?my_position( X, Y, Z );
    !distance(P, pos(X, Y, Z));
    ?distance( D );
    if(D < 80){
        .println("Cerca");
        !add_task(task(3000,"TASK_GOTO_POSITION", A, pos(X, Y, Z), ""));
        -+state(standing);
    }
    -goto_kill(_,_,_).
    
+goto_kill(P)[source(A)] : iaimed("true")
<-
    .println("Recibido mensaje goto de ", A, "     aimed = true");
    -goto_kill(_,_,_).

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")}.  
