within AixLib.Building.Benchmark.InternalLoads;
model InternalLoads
  InternalLoads_Power internalLoads_Power
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  InternalLoads_Water internalLoads_Water
    annotation (Placement(transformation(extent={{-10,-70},{10,-50}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b AddPower[5]
    annotation (Placement(transformation(extent={{84,50},{104,70}})));
  Modelica.Blocks.Sources.CombiTimeTable combiTimeTable1(
                                                        tableOnFile=true,
    final fileName=
        "D:/aku-bga/AixLib/AixLib/Building/Benchmark/InternalLoads/InternalLoads_v1.mat",
    tableName="final",
    timeScale=1,
    columns={2,3,4,5,6,7,8,9,10,11})
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));

  BusSystem.InternalBus internalBus
    annotation (Placement(transformation(extent={{72,-40},{112,-80}})));
equation
  connect(internalLoads_Power.AddPower, AddPower)
    annotation (Line(points={{10,60},{94,60}}, color={191,0,0}));
  connect(internalLoads_Power.u1, combiTimeTable1.y) annotation (Line(points={{
          -10,60},{-40,60},{-40,0},{-59,0}}, color={0,0,127}));
  connect(internalLoads_Water.u1, combiTimeTable1.y) annotation (Line(points={{
          -10,-60},{-40,-60},{-40,0},{-59,0}}, color={0,0,127}));
  connect(internalLoads_Water.y1[1], internalBus.InternalLoads_MFlow_Openplanoffice)
    annotation (Line(points={{10,-60.8},{32,-60.8},{32,-60},{54.1,-60},{54.1,
          -60.1},{92.1,-60.1}}, color={0,0,127}));
  connect(internalLoads_Water.y1[2], internalBus.InternalLoads_MFlow_Conferenceroom)
    annotation (Line(points={{10,-60.4},{34,-60.4},{34,-60},{56.1,-60},{56.1,
          -60.1},{92.1,-60.1}}, color={0,0,127}));
  connect(internalLoads_Water.y1[3], internalBus.InternalLoads_MFlow_Multipersonoffice)
    annotation (Line(points={{10,-60},{56,-60},{56,-60.1},{92.1,-60.1}}, color=
          {0,0,127}));
  connect(internalLoads_Water.y1[4], internalBus.InternalLoads_MFlow_Canteen)
    annotation (Line(points={{10,-59.6},{36,-59.6},{36,-60},{60.1,-60},{60.1,
          -60.1},{92.1,-60.1}}, color={0,0,127}));
  connect(internalLoads_Water.y1[5], internalBus.InternalLoads_MFlow_Workshop)
    annotation (Line(points={{10,-59.2},{34,-59.2},{34,-60},{56.1,-60},{56.1,
          -60.1},{92.1,-60.1}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end InternalLoads;