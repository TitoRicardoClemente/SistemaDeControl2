clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2024
% Tarea 1 Lazo Cerrado - Realimentacion Unitaria
% =======

% Ceros
c=[0];

% Polos
p=[0 -1];

% Ganancia
k=5;

% Tiempo de Muestreo
Tm=0.09;
G=zpk(c,p,k);

Gd=c2d(G,Tm,'zoh');
Gd1=c2d(G,10*Tm,'zoh');

figure(1)
rlocus(G,'r');
legend('Sistema Continuo G(s)');
figure(2)
rlocus(Gd,'b',Gd1,'k');
legend('Sistema Discreto Gd(s)', 'Sistema Discreto Gd(s) Tm*10');
