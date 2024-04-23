clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Motor CC - CASO 2 - Sistema de tres variables de estado
% ITEM 6 - Modelo 

% Ve: tensión de entrada [Volts]
% L: inductancia [Henrios]
% C: capacidad [Faradios]
% R: resistencia [Ohms]
% Vr: tensión de salida (en la resistencia) [Volts]
% i: corriente
% tita: angulo de giro [rad]

%Constantes del PID 
%Kp=0.1;Ki=0.01;Kd=5;
Kpv=[0.1 0.5 1 10 1000];      %kp=1000
Kiv=[3.5e7 4e7 5e7 6e7 5e8];  %ki=5e8
Kdv=[1 0 0 0 0];              %kd=0
for jj=1:5
Kp=Kpv(jj);
Ki=Kiv(jj);
Kd=Kdv(jj);

X=-[0; 0; 0; 0];ii=0;t_etapa=1e-7;titaRef=1;tF=.2;
Ts=t_etapa; 
A1=((2*Kp*Ts)+(Ki*(Ts^2))+(2*Kd))/(2*Ts); 
B1=(-2*Kp*Ts+Ki*(Ts^2)-4*Kd)/(2*Ts); 
C1=Kd/Ts; 
e=zeros(round(tF/t_etapa),1); 
u=0;u_max=12; 
TL=1e-3;
for t=0:t_etapa:tF 
    ii=ii+1;k=ii+2; 
    X=modmotor4(t_etapa, X, u,TL); 
    e(k)=titaRef-X(4); %ERROR 
    u=u+A1*e(k)+B1*e(k-1)+C1*e(k-2); %PID 
    x1(ii)=X(1);% Omega 
    x2(ii)=X(2);% wp 
    x3(ii)=X(3);% ia 
    x4(ii)=X(4);% tita 
    u=u_max*tanh(u/u_max); % termina la acción de control en 12V. 
    acc(ii)=u; 
end 
  
t=0:t_etapa:tF; 
subplot(3,1,1);hold on; 
plot(t,x4);title('Salida posición \tita_t'); 
subplot(3,1,2);hold on; 
plot(t,x3);title('Corriente I_a'); 
subplot(3,1,3);hold on; 
plot(t,acc);title('Entrada V_a'); 
xlabel('Tiempo [Seg.]'); 
end

function [X]=modmotor4(t_etapa, xant, accion,TL) 
Laa=366e-6; J=5e-9;Ra=55.6;B=0;Ki=6.49e-3;Km=6.53e-3; 
Va=accion; 
h=1e-7; 
omega=xant(1); 
wp=xant(2); 
ia=xant(3); 
tita=xant(4); 
for ii=1:t_etapa/h 
    wpp =(-wp*(Ra*J+Laa*B)-omega*(Ra*B+Ki*Km)+Va*Ki+Ra*TL)/(J*Laa); 
    iap=(-Ra*ia-Km*omega+Va)/Laa; 
    wp=wp+h*wpp; 
    ia=ia+h*iap; 
    omega=omega+h*wp; 
    tita=tita+h*omega; 
end 
X=[omega,wp,ia,tita]; 
end