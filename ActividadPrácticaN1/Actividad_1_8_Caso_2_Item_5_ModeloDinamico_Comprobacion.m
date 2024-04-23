clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Motor CC - CASO 2 - Sistema de tres variables de estado
% ITEM 5 - Comprobacion de valores
J =4.9562e-05;
Bm =8.9585e-15;
Laa =4.1583e-05;
Ra =1.6646;
Km = 198;
Ki =0.0051;
% Defino las matrices de estados
A=[-Ra/Laa -Km/Laa 0; Ki/J -Bm/J 0; 0 1 0];
B=[1/Laa 0; 0 -1/J; 0 0];
C=[0 1 0];
D=[0 0];

tiempo_d = xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','A:A');
u=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','D:D');
tL=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','E:E');

% Simulación
t_S=tiempo_d(2)-tiempo_d(1);            %tiempo de simulación
tF=tiempo_d(end);                       %tiempo final
h=tF/t_S;  

Xop=[0;0;0];              % punto de operación 
Xp=[0;0;0];               % Matriz auxiliar para las variables de estado derivadas
X=[0;0;0];                % Matriz de variable de estado 
U=[0;0];                  % Matriz de entradas tensión y torque
    
for ii=1 : length(tiempo_d)
    U(1)=u(ii);
    U(2)=tL(ii);
    Xp = A*(X-Xop) + B*U;
    X  = X + Xp*t_S;
    ia(ii)=X(1);
    wr(ii)=X(2);
    theta(ii)=X(3);
end

figure(1)
subplot(4,1,1);plot(tiempo_d,wr,'r');title('\omega - Velocidad Angular');hold on
subplot(4,1,2);plot(tiempo_d,ia,'b');title('i_a - Corriente');hold on
subplot(4,1,3);plot(tiempo_d,u,'g');title('V_a - Tension');hold on
subplot(4,1,4);plot(tiempo_d,tL,'m');title('\tau - Torque');hold on
