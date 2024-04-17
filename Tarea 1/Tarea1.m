clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2024
% Tarea 1 Lazo Abierto
% =======

% Ceros
c=[0];

% Polos
p=[0 -1];

% Ganancia
k=5;

% Tiempo de Muestreo
Tm=0.09;
G=zpk(c,p,k)

Gd=c2d(G,Tm,'zoh')

% Calculo de la Ganancia de la Funcion Discreta
kd=dcgain(Gd);
F=feedback(Gd,1);

figure(1)
step(F)
figure(2)
step(G,'r',Gd,'g');hold on;
figure(3)
pzmap(G,'g',Gd,'r')
figure(4)
pzmap(c2d(G,Tm*10,'zoh'))

% Rampa de Entrada
t=0:Tm:100*Tm; 

lsim(F,t,t)
figure(5)
step(F)
