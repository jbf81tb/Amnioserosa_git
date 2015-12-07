function Cfxyswn=Concentration_Center_Code(fxyc_struct)

[DVSMapa]=DistVelStrianMap(fxyc_struct);
save dvsmapa.mat DVSMapa
% load dvsmap2.mat DVSMap2
% CenterMap=CentersofExp(DVSMap3);
% % save centmap.mat CenterMap
% % load centmap.mat CenterMap
% fxyswn=LocateCenters(CenterMap);
% % save spots.mat fxyswn
% Cfxyswn=TrackCenters(fxyswn);
% % save centers.mat Cfxyswn
end