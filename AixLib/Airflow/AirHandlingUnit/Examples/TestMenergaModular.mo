﻿within AixLib.Airflow.AirHandlingUnit.Examples;
model TestMenergaModular "Example model to test the MenergaModular model"

    //Medium models
  replaceable package MediumAir = AixLib.Media.Air;
  replaceable package MediumWater = AixLib.Media.Water;

  extends Modelica.Icons.Example;
  Fluid.Sources.Boundary_pT supplyAir(
    redeclare package Medium = MediumAir,
    nPorts=1,
    X={0.02,0.98},
    p=100000,
    T=294.15) "Sink for supply air"
    annotation (Placement(transformation(extent={{-100,-34},{-80,-14}})));
  Fluid.Sources.Boundary_pT outsideAir(
    redeclare package Medium = MediumAir,
    nPorts=1,
    X={0.005,0.995},
    use_T_in=true,
    p=100000,
    T=283.15) "Source for outside air"
    annotation (Placement(transformation(extent={{84,-32},{64,-12}})));
  Fluid.Sources.Boundary_pT exhaustAir(
    redeclare package Medium = MediumAir,
    nPorts=1,
    p=100000,
    T=296.15,
    X={0.01,0.99})
              "Source for exhaust air"
    annotation (Placement(transformation(extent={{-100,-6},{-80,14}})));
  Fluid.Sources.Boundary_pT exitAir(
    redeclare package Medium = MediumAir,
    nPorts=1,
    X={0.01,0.99},
    p=100000,
    T=283.15) "Sink für exit air" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,50})));
  BaseClasses.Controllers.MenergaController menergaController
    annotation (Placement(transformation(extent={{-8,74},{12,94}})));
  Modelica.Fluid.Sources.Boundary_pT WatSou(
    nPorts=1,
    redeclare package Medium = MediumWater,
    T=318.15) "Water source" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-42,-86})));
  Modelica.Fluid.Sources.Boundary_pT WatSin(nPorts=1, redeclare package Medium =
        MediumWater) "Water sink" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-14,-86})));
  MenergaSorpTest menergaModular(redeclare package MediumAir = MediumAir,
      redeclare package MediumWater = MediumWater)
    annotation (Placement(transformation(extent={{-48,-36},{52,10}})));
  Modelica.Blocks.Sources.BooleanExpression On(y=true)
    annotation (Placement(transformation(extent={{-64,36},{-44,56}})));
  Modelica.Blocks.Sources.Step step(
    offset=10 + 273.15,
    startTime=900,
    height=0)
    annotation (Placement(transformation(extent={{124,-28},{104,-8}})));
equation
  connect(outsideAir.ports[1], menergaModular.outsideAir) annotation (Line(
        points={{64,-22},{52,-22},{52,-23.4}}, color={0,127,255}));
  connect(supplyAir.ports[1], menergaModular.supplyAir) annotation (Line(points={{-80,-24},
          {-80,-23.4},{-48,-23.4}},             color={0,127,255}));
  connect(exhaustAir.ports[1], menergaModular.exhaustAir)
    annotation (Line(points={{-80,4},{-48,4.2}},  color={0,127,255}));
  connect(exitAir.ports[1], menergaModular.ExitAir) annotation (Line(points={{
          -1.77636e-015,40},{0,40},{0,10},{13.2,10}},
                                              color={0,127,255}));
  connect(menergaController.busActors, menergaModular.busActors) annotation (
      Line(
      points={{12,80.4},{21.8,80.4},{21.8,10},{21.2,10}},
      color={255,204,51},
      thickness=0.5));
  connect(menergaModular.busSensors, menergaController.busSensors) annotation (
      Line(
      points={{-16.2,10},{-16.2,80.6},{-8,80.6}},
      color={255,204,51},
      thickness=0.5));
  connect(WatSou.ports[1], menergaModular.watInlHeaCoi) annotation (Line(points={{-42,-76},
          {-42,-70},{-29.2,-70},{-29.2,-36}},       color={0,127,255}));
  connect(WatSin.ports[1], menergaModular.watOutHeaCoi) annotation (Line(points={{-14,-76},
          {-14,-70},{-26.8,-70},{-26.8,-36}},                color={0,127,255}));
  connect(On.y, menergaModular.OnSignal) annotation (Line(points={{-43,46},{-26,
          46},{-26,10.8},{-25.6,10.8}}, color={255,0,255}));
  connect(step.y, outsideAir.T_in)
    annotation (Line(points={{103,-18},{86,-18}}, color={0,0,127}));
  annotation (experiment(StopTime=1800, Interval=10));
end TestMenergaModular;