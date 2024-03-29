clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID 
% ===================================================================
% Circuito RLC - CASO 3
% Ve: tensión de entrada [Volts]
% L: inductancia [Henrios]
% C: capacidad [Faradios]
% R: resistencia [Ohms]
% Vr: tensión de salida (en la resistencia) [Volts]
% i: corriente

%Cargar Datos
datos_ex= xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1');
% guardo los datos del excel en una variable 
tiempo = xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','A:A');
% tomo solamente los valores mayores a 0 Voltios
corriente_L=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','B:B');
tension_C=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','C:C');

%Defino un nuevo tiempo para poder relacionarlo con las correspondientes
%tensiones y corrientes
aux=0:1e-4:((length(tension_C)-1)*1e-4);
tiempo_S=aux';
%{
t_inicial=10e-3; % tiempo inicial en 10 mili Segundos
% busca el tiempo inicial en la lista de valores del arreglo "tiempo" 
% y lo guarde en una variable "punto"
[~,punto]=min(abs(t_inicial-tiempo_S));
t_t1=tiempo_S(punto);      % t1 el tiempo correspondiente al t_inicial
y_1=tension_C(punto);    % y(t1)la tensión en C donde el tiempo=t_inicial
[~,punto]=min(abs(2*t_inicial-tiempo_S));
t_2t1=tiempo_S(punto);     % 2*t1 el tiempo correspondiente al t_inicial
y_2=tension_C(punto);    % y(2*t1)la tensión en C donde el tiempo=t_inicial
[~,punto]=min(abs(3*t_inicial-tiempo_S));
t_3t1=tiempo_S(punto);     % 3*t1el tiempo correspondiente al t_inicial
y_3=tension_C(punto);    % y(3*t1)la tensión en C donde el tiempo=t_inicial

% Defino el Entrada Escalón del Sistema
entr=stepDataOptions('InputOffset',0,'StepAmplitude',1);
% Conciderando la salida como el último valor de la Tensión en C:
K=tension_C(408)/entr.StepAmplitude;
k1=(y_1/K)-1;
k2=(y_2/K)-1;
k3=(y_3/K)-1;

% Ecuaciones desarrolladas bajo el supesto T1<T2 y alfa1<alfa2
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3; 
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2)); 
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2)); 
beta=(k1+alfa2)/(alfa1-alfa2);

% Remplazo en los valores de las constantes de tiempo T1, T2 y T3:
T_1=-t_t1/log(alfa1); 
T_2=-t_t1/log(alfa2); 
T_3=beta*(T_1-T_2)+T_1; 

% Sistema Aproximado Final:
G_s=tf(K*[T_3 1],conv([T_2 1],[T_1 1]))
G_s=zpk(G_s)
%}
% Sistema Original por Datos 
plot(tiempo,tension_C,'red'); hold on
% Sistema Aproximado. 
%{
step(G_s,entr) 
title('Curvas Medidas RLC / Curva Aproximada')
xlabel('Tiempo [segundos]')
ylabel('Amplitud Tensión en Capacitor')
%}