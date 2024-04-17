clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2024
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Circuito RLC
% Ve: tensión de entrada [Volts]
% L: inductancia [Henrios]
% C: capacidad [Faradios]
% R: resistencia [Ohms]
% Vr: tensión de salida (en la resistencia) [Volts]
% i: corriente

% Variables de Estado de sistema eléctrico
% Entrada u=Ve
% x1 = i ; x1p=(u-x2-x1*R)*(1/L)
% x2 = Vc ; x2p=(x1)*(1/C)
% Salida y=x1*R

% [x1p ; x2p] = [-R/L -1/L; 1/C 0]*[x1;x2] + [1/L;0] * u
% y = [R 0] * [x1;x2]

% Definicón de las Matrices y los valores de Cada Variable
% Variables
R= 268.9955;  % 269 [Ohms]
L= 98.6e-3;   % 98.6 [mHy]
cap= 1e-05;   % 10 [uF]
% Matrices
A= [-R/L -1/L; 1/cap 0];
B=[1/L; 0];
C=[R 0];
D=[0];

% Calculo de la  
[num,deno]=ss2tf(A,B,C,D);
G=tf(num,deno);
tiempo_d = xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','A:A');
corriente_L=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','B:B');
escalon_d=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','D:D');

% Defino la entrada
[u,t,i_S]=Entrada(tiempo_d,escalon_d,corriente_L,length(tiempo_d));

tI=tiempo_d(2)-tiempo_d(1); h=length(t);
% Defino las variables y sus datos a guardar
vc=[h];         % defino variable de estado x2
vr=[h];         % defino variable de salida y
i=[h];

% Variables de estados, inicialización
X=[0; 0];     % x1 = 0 , x2 = 0 
Y=[0];        % y = 0

for j=1:1:h
    % guardo el valor correspondiente a cada variable a graficar
    i(j)=X(1);  
    vc(j)=X(2);
    vr(j)=Y(1);
    
    % ecuaciones deferenciales de primer orden del sistema monovariable
    Xp=A*X+B*u(j);  % Ecuación de Estados
    X=X+tI*Xp;      % Método de Euler definido tI=1useg * dx
    Y=C*X;
end

figure(1);
plot(t,i,'b');hold on;
plot(t,i_S,'r');hold on;
title('x_1 = Corriente');xlabel('segundos [sec]');ylabel('Ampere')
xlabel('Tiempo [s]');

function [U,T,I]=Entrada(t,Ve,I,iteracion)
    t_aux=[];
    ve_aux=[];
    i_aux=[];
    j=1;
    t_inic=0;
    for i=1:1:iteracion
      if t(i)>=0.05  
          if j==1
          t_inic=t(i);% valor inicial
          end
          t_aux(j)=t(i)-t_inic;
          ve_aux(j)=Ve(i);
          i_aux(j)=I(i);
          j=j+1;
      end
    end
I=i_aux;
T=t_aux;
U=ve_aux;
end