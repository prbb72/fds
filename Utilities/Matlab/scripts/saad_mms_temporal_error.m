%!/usr/bin/matlab
%McDermott
%7-29-2015
%saad_mms_temporal_error.m

close all
clear all

% Problem 1 parameters
r = 0.5;
nx = 512;
L = 2;
dx = L/nx;
x = dx/2:dx:L-dx/2;
rho__0 = 5;
rho__1 = .5;
f = .5*(1+sin(2*pi*x/L));
rho = 1./((1-f)./rho__0 + f./rho__1);
% plot(x,rho)
% return
% T = 0.00390625; % total simulation time (CFL=1)
% dt = [T .5*T .25*T .125*T .0625*T];

% Output files

datadir = '../../Verification/Scalar_Analytical_Solution/';
plotdir = '../../Manuals/FDS_Verification_Guide/SCRIPT_FIGURES/';
filename = {'saad_512_cfl_1_mms.csv', ...
            'saad_512_cfl_p5_mms.csv', ...
            'saad_512_cfl_p25_mms.csv', ...
            'saad_512_cfl_p125_mms.csv', ...
            'saad_512_cfl_p0625_mms.csv'};

skip_case = 0;

for n=1:length(filename)
    if ~exist([datadir,filename{n}])
        display(['Error: File ' [datadir,filename{n}] ' does not exist. Skipping case.'])
        skip_case = 1;
    end
end

if skip_case
    return
end

% Gather FDS results

n=2;
M1 = importdata([datadir,filename{n+1}],',',2);
M2 = importdata([datadir,filename{n+2}],',',2);
M3 = importdata([datadir,filename{n+3}],',',2);

ii = [nx+1:2*nx];
rho_1 = M1.data(ii,1);
rho_2 = M2.data(ii,1);
rho_3 = M3.data(ii,1);
Z_1 = M1.data(ii,2);
Z_2 = M2.data(ii,2);
Z_3 = M3.data(ii,2);

p_rho = log( abs(rho_3-rho_2)./abs(rho_2-rho_1) )./log(r);
p_Z = log( abs(Z_3-Z_2)./abs(Z_2-Z_1) )./log(r);

disp('Saad temporal order')
disp(' ')
disp(['L1 p rho = ',num2str( norm(p_rho,1)/nx )])
disp(['L2 p rho = ',num2str( norm(p_rho,2)/sqrt(nx) )])
% disp(['Linf p rho = ',num2str( norm(p_rho,inf) )])
disp(' ')
disp(['L1 p Z = ',num2str( norm(p_Z,1)/nx )])
disp(['L2 p Z = ',num2str( norm(p_Z,2)/sqrt(nx) )])
% disp(['Linf p Z = ',num2str( norm(p_Z,inf) )])

% flag errors

L2_rho = norm(p_rho,2)/sqrt(nx);
if L2_rho<1.99
    disp(['Matlab Warning: L2_rho = ',num2str(L2_rho),' in Saad MMS'])
end

L2_Z = norm(p_Z,2)/sqrt(nx);
if L2_Z<1.99
    disp(['Matlab Warning: L2_Z = ',num2str(L2_Z),' in Saad MMS'])
end

Git_Filename = [datadir,'saad_512_cfl_p0625_git.txt'];
plot_style

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X,Plot_Y,Plot_Width,Plot_Height])
set(gca,'FontName',Font_Name)
set(gca,'FontSize',Title_Font_Size)
plot(p_rho)
xlabel('cell index')
ylabel('p order density')
addverstr(gca,Git_Filename,'linear')
print(gcf,'-dpdf',[plotdir,'saad_temporal_order_rho'])

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X,Plot_Y,Plot_Width,Plot_Height])
set(gca,'FontName',Font_Name)
set(gca,'FontSize',Title_Font_Size)
plot(p_Z)
xlabel('cell index')
ylabel('p order mixture fraction')
addverstr(gca,Git_Filename,'linear')
print(gcf,'-dpdf',[plotdir,'saad_temporal_order_Z'])

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X,Plot_Y,Plot_Width,Plot_Height])
set(gca,'FontName',Font_Name)
set(gca,'FontSize',Title_Font_Size)
plot(x,rho,'r--'); hold on
plot(x,rho_3,'r-')
xlabel('{\it x} (m)')
ylabel('density (kg/m^3)')
legend('initial field','final field','location','northwest')
addverstr(gca,Git_Filename,'linear')
print(gcf,'-dpdf',[plotdir,'saad_rho'])

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X,Plot_Y,Plot_Width,Plot_Height])
set(gca,'FontName',Font_Name)
set(gca,'FontSize',Title_Font_Size)
plot(x,f,'b--'); hold on
plot(x,Z_3,'b-')
xlabel('{\it x} (m)')
ylabel('mixture fraction, {\it Z}')
legend('initial field','final field','location','northeast')
addverstr(gca,Git_Filename,'linear')
print(gcf,'-dpdf',[plotdir,'saad_Z'])


