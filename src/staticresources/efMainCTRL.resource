eventFlex.controller('MainCTRL', ['$scope', 'efSERVICES', '$routeParams', '$location', function($scope, efSERVICES, $routeParams, $location) {
  $scope.toSession = 'a012000001eRAdzAAG';
  $scope.test = '¡Hola, amigo!';
  $scope.events = [];
  $scope.isLoading = false;
  $scope.modalShown = false;
  
   $scope.goTo = function(evtId){
    console.debug(evtId);
    urlstr = '#/session/'+evtId;
    $location.path(urlstr);
    //sforce.one.navigateToSObject(evtId);
    //sforce.one.navigateToURL(urlstr);
  }

  $scope.navigateTo = function(recid){
    var navto = '/'+recid;
    sforce.one.navigateToURL(navto);
  }

  $scope.loadData = function(){
    if($scope.events.length > 0){
      
      return;
    }else{
      $scope.isLoading = true;
      efSERVICES.getAllEvents(function(data){
        $scope.events = data;
        $scope.isLoading = false;
        $scope.$apply($scope.events);
        $scope.$apply($scope.isLoading);
      });
    }
  }

  $scope.init = function(){
    
    $scope.loadData();
  }

  $scope.toggleModal = function(){
    $scope.modalShown = !$scope.modalShown;
  };

  $scope.init();


}]);

eventFlex.controller('SessionModalCTRL', ['$scope', 'efSERVICES', '$routeParams', function($scope, efSERVICES, $routeParams){
  $scope.test = 'MODAL YAHHH';

}]);

eventFlex.controller('AnalyticsCTRL', ['$scope', 'efSERVICES', '$routeParams', function($scope, efSERVICES, $routeParams){
  $scope.test = 'MODAL YAHHH';

}]);



eventFlex.service('chartServices', function(){
         return{

getDashboardForEvent : function(eventId, callback){
                 Visualforce.remoting.Manager.invokeAction(staticItems['getDashboardForEvent'],eventId, function(result, event){
                    if( event.status ) {
                        callback(result);
                    }
                });
            }
        }
    });


// Main Controller
eventFlex.controller('AnalyticsCTRL', function($scope, chartServices, $routeParams) {
    
    $scope.eventId = $routeParams.id;

    $scope.charts = [];

    console.debug('----- SERVICES-----')

    $scope.config = {
    title: 'Open Cases',
    tooltips: true,
    labels: false,
    mouseover: function() {},
    mouseout: function() {},
    click: function() {},
    legend: {
      display: true,
      //could be 'left, right'
      position: 'right'
    }
  };

  $scope.init = function(){

    console.debug('----- SERVICES-----')

    chartServices.getDashboardForEvent($scope.eventId, function(results){
      
      $scope.data = results.efReports[0];
      $scope.$apply($scope.data);

      console.debug(results);
    });
  }

  $scope.init();


});





eventFlex.controller('SessionCTRL', ['$scope', 'efSERVICES', '$routeParams', function($scope, efSERVICES, $routeParams) {
  $scope.eventId = $routeParams.id;
  $scope.sessions = [];
  $scope.sessionData = [];
  $scope.sessionTopicData = {};
  $scope.sessionSpeakerData = {};
  $scope.eventDetails = {};
  $scope.eventDates = [];
  $scope.featuredSpeakers = [];
  $scope.currEvtDate;
  $scope.filterCriteria;
  $scope.friendsAttendance = {};
  $scope.sessionList = {};

  $scope.activeTab = 'Future';


  $scope.isLoading = false;
  $scope.gData = [];
  $scope.groupByOptions = [{'Label' : 'Location', 'isArr':false, 'Property':'Location_text__c'}, {'Label' : 'Speaker', 'isArr' : true, 'ArrName':'Speakers', 'Property' : 'Speaker_Name__c'}, {'Label' : 'Topics', 'isArr' : true, 'ArrName':'Topics', 'Property' : 'Name'}];
  $scope.groupBy = {};

  $scope.modalURL = staticItems['efSessionModalHTML'];

  $scope.test = 'Adios, muchacho!';

  $scope.templateURL =  staticItems['ganttTemplate'];
  $scope.modalShown = false;


 $scope.raiseCase = function(){
   sforce.one.createRecord('Case');
 }

 $scope.searchForText = function(newText){
  $scope.filterCriteria = newText;
 }

  $scope.refreshGrid = function(groupBy){
    $scope.groupBy = groupBy;

    if(groupBy.isArr){
      $scope.sessions = efSERVICES.groupDataByArray($scope.sessionData, $scope.groupBy.ArrName, $scope.groupBy.Property);
    }else{
      $scope.sessions = efSERVICES.groupDataByProperty($scope.sessionData, $scope.groupBy.Property);
    }

    $scope.getGanttData();
  }

  $scope.getDate = function(dt){
    if(dt!=null){
    return new Date(dt);
    }
  }

  $scope.processData = function(){
     
      $scope.sessionData = efSERVICES.enhanceData($scope.sessionData, $scope.sessionSpeakerData, 'Speakers');
      $scope.sessionData = efSERVICES.enhanceData($scope.sessionData, $scope.sessionTopicData,'Topics');
      $scope.sessionData = efSERVICES.enhanceData($scope.sessionData, $scope.friendsAttendance,'ContactAttendance');
      console.debug('SESSION DATA');
      console.debug($scope.sessionData);

      $scope.refreshGrid($scope.groupByOptions[0]);

      $scope.isLoading = false;
      $scope.sessionList = {};
      angular.forEach( $scope.sessionData, function(session){
          var dt = new Date(session._props.Start_date_time__c);

          if($scope.sessionList[dt] == null){
            $scope.sessionList[dt] = [session];

          }else{
            $scope.sessionList[dt].push(session);
          }

      });


      $scope.$apply($scope.sessionData);
      $scope.$apply($scope.sessions);
      $scope.$apply($scope.isLoading);

  }

  $scope.getSessionData = function(sessionId){
    for(var i=0; i<$scope.sessionData.length; i++){
      if($scope.sessionData[i]._props.Id == sessionId){
        return $scope.sessionData[i];
      }
    }
  }

  function generateDates(evt){
    $scope.eventDates = [];
    var startdt = new Date(evt._props.Start_date_time__c);
    var enddt = new Date(evt._props.End_date_time__c);

    console.debug('STARTDT'+startdt);

    var tempdt = new Date(startdt);
    
    while(tempdt <= enddt){
       $scope.eventDates.push(new Date(tempdt));
       tempdt.setDate(tempdt.getDate()+1);


       
    }

    $scope.currEvtDate = $scope.eventDates[0];

  }

  $scope.changeDate = function(newDt){
    $scope.currEvtDate = newDt;
    $scope.loadSessions();
  }
  
  $scope.loadSessions = function(){
     $scope.sessionData = [];
    efSERVICES.getSessionsForEvent($scope.eventId, $scope.currEvtDate, function(data){
        $scope.sessionData = data;

        console.debug(data);

        efSERVICES.getMyFriendsAttendance($scope.eventId, function(dataA){
        $scope.friendsAttendance = dataA;
        
        });

        efSERVICES.getSessionSpeakers($scope.eventId, function(dataS){
          $scope.sessionSpeakerData = dataS;

         

          efSERVICES.getSessionTopics($scope.eventId, function(dataT){
            $scope.sessionTopicData = dataT;
            
            $scope.processData();

          });
        
      });
    });
  }

  $scope.loadData = function(){
      $scope.isLoading = true;
      

      

      efSERVICES.getEventDetails($scope.eventId, function(data){
        $scope.eventDetails = data;
        
        console.debug($scope.eventDetails);

        generateDates($scope.eventDetails);

        $scope.$apply( $scope.currEvtDate);
        $scope.$apply($scope.eventDetails);

      

      efSERVICES.getEventSpeakers($scope.eventId, function(data){
        $scope.featuredSpeakers = data;
         $scope.$apply($scope.featuredSpeakers);
      });

      $scope.loadSessions();

     
       
      });
  }

  $scope.getGanttData = function(){
    var i = 0;
    $scope.gData = [];
    angular.forEach($scope.sessions, function(gevt){

      var tempEvt = {'id':gevt.key, 'order':i, 'description' : gevt.key, 'tasks' : []};
      
      for(var x=0; x<gevt.data.length; x++){
          var evt = gevt.data[x];

          tempEvt.tasks.push({'id' : evt._props.Id, 'subject' : evt._props.Name,  "color": "#F1C232", 'from' : new Date(evt._props.Start_date_time__c), 'to' : new Date(evt._props.End_date_time__c)});
      };

      $scope.gData.push(tempEvt);
      
      i++;
    });


    $scope.clearGanttData();

    $scope.loadGanttData($scope.gData);

    

  }

  $scope.viewSession = function(evtId){

    $scope.sessionDetails = $scope.getSessionData(evtId);

    console.debug($scope.sessionDetails);
   
    $scope.modalShown = !$scope.modalShown;
    
  };

  $scope.init = function(){
    $scope.loadData();
  }

 

  $scope.ganttData = {"data1": [
            // Order is optional. If not specified it will be assigned automatically
            {"id": "2f85dbeb-0845-404e-934e-218bf39750c0", "description": "Milestones", "order": 0, "tasks": [
                // Dates can be specified as string, timestamp or javascript date object. The data attribute can be used to attach a custom object
                {"id": "f55549b5-e449-4b0c-9f4b-8b33381f7d76", "subject": "Kickoff", "color": "#93C47D", "from": "2013-10-07T09:00:00", "to": "2013-10-07T10:00:00", "data": "Can contain any custom data or object"},
                {"id": "5e997eb3-4311-46b1-a1b4-7e8663ea8b0b", "subject": "Concept approval", "color": "#93C47D", "from": new Date(2013,9,18,18,0,0), "to": new Date(2013,9,18,18,0,0), "est": new Date(2013,9,16,7,0,0), "lct": new Date(2013,9,19,0,0,0)},
                {"id": "b6a1c25c-85ae-4991-8502-b2b5127bc47c", "subject": "Development finished", "color": "#93C47D", "from": new Date(2013,10,15,18,0,0), "to": new Date(2013,10,15,18,0,0)},
                {"id": "6fdfd775-7b22-42ec-a12c-21a64c9e7a9e", "subject": "Shop is running", "color": "#93C47D", "from": new Date(2013,10,22,12,0,0), "to": new Date(2013,10,22,12,0,0)},
                {"id": "c112ee80-82fc-49ba-b8de-f8efba41b5b4", "subject": "Go-live", "color": "#93C47D", "from": new Date(2013,10,29,16,0,0), "to": new Date(2013,10,29,16,0,0)}
            ], "data": "Can contain any custom data or object"},
            {"id": "b8d10927-cf50-48bd-a056-3554decab824", "description": "Status meetings", "order": 1, "tasks": [
                {"id": "301d781f-1ef0-4c35-8398-478b641c0658", "subject": "Demo", "color": "#9FC5F8", "from": new Date(2013,9,25,15,0,0), "to": new Date(2013,9,25,18,30,0)},
                {"id": "0fbf344a-cb43-4b20-8003-a789ba803ad8", "subject": "Demo", "color": "#9FC5F8", "from": new Date(2013,10,1,15,0,0), "to": new Date(2013,10,1,18,0,0)},
                {"id": "12af138c-ba21-4159-99b9-06d61b1299a2", "subject": "Demo", "color": "#9FC5F8", "from": new Date(2013,10,8,15,0,0), "to": new Date(2013,10,8,18,0,0)},
                {"id": "73294eca-de4c-4f35-aa9b-ae25480967ba", "subject": "Demo", "color": "#9FC5F8", "from": new Date(2013,10,15,15,0,0), "to": new Date(2013,10,15,18,0,0)},
                {"id": "75c3dc51-09c4-44fb-ac40-2f4548d0728e", "subject": "Demo", "color": "#9FC5F8", "from": new Date(2013,10,24,9,0,0), "to": new Date(2013,10,24,10,0,0)}
            ]},
            {"id": "c65c2672-445d-4297-a7f2-30de241b3145", "description": "Kickoff", "order": 2, "tasks": [
                {"id": "4e197e4d-02a4-490e-b920-4881c3ba8eb7", "subject": "Day 1", "color": "#9FC5F8", "from": new Date(2013,9,7,9,0,0), "to": new Date(2013,9,7,17,0,0)},
                {"id": "451046c0-9b17-4eaf-aee0-4e17fcfce6ae", "subject": "Day 2", "color": "#9FC5F8", "from": new Date(2013,9,8,9,0,0), "to": new Date(2013,9,8,17,0,0)},
                {"id": "fcc568c5-53b0-4046-8f19-265ebab34c0b", "subject": "Day 3", "color": "#9FC5F8", "from": new Date(2013,9,9,8,30,0), "to": new Date(2013,9,9,12,0,0)}
            ]},
            {"id": "dd2e7a97-1622-4521-a807-f29960218785", "description": "Create concept", "order": 3, "tasks": [
                {"id": "9c17a6c8-ce8c-4426-8693-a0965ff0fe69", "subject": "Create concept", "color": "#F1C232", "from": new Date(2013,9,10,8,0,0), "to": new Date(2013,9,16,18,0,0), "est": new Date(2013,9,8,8,0,0), "lct": new Date(2013,9,18,20,0,0)}
            ]},
            {"id": "eede0c9a-6777-4b55-9359-1eada309404e", "description": "Finalize concept", "order": 4, "tasks": [
                {"id": "30b8f544-5a45-4357-9a72-dd0181fba49f", "subject": "Finalize concept", "color": "#F1C232", "from": new Date(2013,9,17,8,0,0), "to": new Date(2013,9,18,18,0,0)}
            ]},
            {"id": "b5318fd9-5d70-4eb1-9c05-65647b9aefe6", "description": "Sprint 1", "order": 5, "tasks": [
                {"id": "d1fdf100-534c-4198-afb9-7bcaef0696f0", "subject": "Product list view", "color": "#F1C232", "from": new Date(2013,9,21,8,0,0), "to": new Date(2013,9,25,15,0,0)}
            ]},
            {"id": "cfb29cd5-1737-4027-9778-bb3058fbed9c", "description": "Sprint 2", "order": 6, "tasks": [
                {"id": "57638ba3-dfff-476d-ab9a-30fda1e44b50", "subject": "Order basket", "color": "#F1C232", "from": new Date(2013,9,28,8,0,0), "to": new Date(2013,10,1,15,0,0)}
            ]},
            {"id": "df9bb83f-e9de-4cbe-944e-36aec6db53cc", "description": "Sprint 3", "order": 7, "tasks": [
                {"id": "192adc6e-ab17-4cd1-82d8-4a5e7525b169", "subject": "Checkout", "color": "#F1C232", "from": new Date(2013,10,4,8,0,0), "to": new Date(2013,10,8,15,0,0)}
            ]},
            {"id": "48cbc052-1fd5-4262-a05f-97dad7337876", "description": "Sprint 4", "order": 8, "tasks": [
                {"id": "431dc7be-b61b-49a0-b26d-7ab5dfcadd41", "subject": "Login&Singup and admin view", "color": "#F1C232", "from": new Date(2013,10,11,8,0,0), "to": new Date(2013,10,15,15,0,0)}
            ]},
            {"id": "34473cc4-5ee5-4953-8289-98779172129e", "description": "Setup server", "order": 9, "tasks": [
                {"id": "43eb6d19-6402-493c-a281-20e59a6fab6e", "subject": "HW", "color": "#F1C232", "from": new Date(2013,10,18,8,0,0), "to": new Date(2013,10,18,12,0,0)}
            ]},
            {"id": "73cae585-5b2c-46b6-aeaf-8cf728c894f7", "description": "Config server", "order": 10, "tasks": [
                {"id": "8dbfda29-e775-4fa3-87c1-103b085d52ee", "subject": "SW / DNS/ Backups", "color": "#F1C232", "from": new Date(2013,10,18,12,0,0), "to": new Date(2013,10,21,18,0,0)}
            ]},
            {"id": "41cae585-ad2c-46b6-aeaf-8cf728c894f7", "description": "Deployment", "order": 11, "tasks": [
                {"id": "2dbfda09-e775-4fa3-87c1-103b085d52ee", "subject": "Depl. & Final testing", "color": "#F1C232", "from": new Date(2013,10,21,8,0,0), "to": new Date(2013,10,22,12,0,0)}
            ]},
            {"id": "33e1af55-52c6-4ccd-b261-1f4484ed5773", "description": "Workshop", "order": 12, "tasks": [
                {"id": "656b9240-00da-42ff-bfbd-dfe7ba393528", "subject": "On-side education", "color": "#F1C232", "from": new Date(2013,10,24,9,0,0), "to": new Date(2013,10,25,15,0,0)}
            ]},
            {"id": "bffa16c6-c134-4443-8e6e-b09410c37c9f", "description": "Content", "order": 13, "tasks": [
                {"id": "2f4ec0f1-cd7a-441a-8288-e788ec112af9", "subject": "Supervise content creation", "color": "#F1C232", "from": new Date(2013,10,26,9,0,0), "to": new Date(2013,10,29,16,0,0)}
            ]},
            {"id": "ec0c5e31-449f-42d0-9e81-45c66322b640", "description": "Documentation", "order": 14, "tasks": [
                {"id": "edf2cece-2d17-436f-bead-691edbc7386b", "subject": "Technical/User documentation", "color": "#F1C232", "from": new Date(2013,10,26,8,0,0), "to": new Date(2013,10,28,18,0,0)}
            ]}
        ]};

      $scope.mode = "date";
    $scope.maxHeight = 0;
    $scope.showWeekends = true;
    $scope.showNonWorkHours = false;

    $scope.scale = 'hour';

   // $scope.loadGanttData = function(){
    //  return $scope.ganttData.data1;
    //}

    $scope.addSamples = function () {
        $scope.loadData();
        //$scope.loadGanttData($scope.ganttData.data1);
    };

    $scope.removeSomeSamples = function () {
        $scope.removeData([
            {"id": "c65c2672-445d-4297-a7f2-30de241b3145"}, // Remove all Kickoff meetings
            {"id": "2f85dbeb-0845-404e-934e-218bf39750c0", "tasks": [
                {"id": "f55549b5-e449-4b0c-9f4b-8b33381f7d76"},
                {"id": "5e997eb3-4311-46b1-a1b4-7e8663ea8b0b"},
                {"id": "6fdfd775-7b22-42ec-a12c-21a64c9e7a9e"}
            ]}, // Remove some Milestones
            {"id": "cfb29cd5-1737-4027-9778-bb3058fbed9c", "tasks": [
                {"id": "57638ba3-dfff-476d-ab9a-30fda1e44b50"}
            ]} // Remove order basket from Sprint 2
        ]);
    };

    $scope.removeSamples = function () {
        $scope.clearData();
    };

    $scope.labelEvent = function(event) {
        // A label has been clicked.
        console.log('Label event (by user: ' + event.userTriggered + '): ' + event.row.description + ' (Custom data: ' + event.row.data + ')');
    };

    $scope.labelHeaderEvent = function(event) {
        // The label header has been clicked.
        console.log('Label header event. Mouse: ' + event.evt.clientX + '/' + event.evt.clientY);
    };

    $scope.rowEvent = function(event) {
        // A row has been added, updated or clicked. Use this event to save back the updated row e.g. after a user re-ordered it.
        console.log('Row event (by user: ' + event.userTriggered + '): ' + event.date + ' '  + event.row.description + ' (Custom data: ' + event.row.data + ')');
    };

    $scope.scrollEvent = function(event) {
        if (angular.equals(event.direction, "left")) {
            // Raised if the user scrolled to the left side of the Gantt. Use this event to load more data.
            console.log('Scroll event: Left');
        } else if (angular.equals(event.direction, "right")) {
            // Raised if the user scrolled to the right side of the Gantt. Use this event to load more data.
            console.log('Scroll event: Right');
        }
    };

    $scope.taskEvent = function(event) {
        // A task has been updated or clicked.
        $scope.viewSession(event.task.id);
    };

}]);




