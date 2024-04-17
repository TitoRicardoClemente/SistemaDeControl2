clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Circuito RLC - CASO 2

Laa=366e-6;
J=5e-9;
Ra=55.6;
B=0;
Ki=6.49e-3;
Km=6.53e-3;

den=[Laa*J Ra*J+Laa*B Ra*B+Ki*Km ];
num=[Ki];
wr_va=tf(num,den);
sys=zpk(wr_va)

sigma1=-1.518e05;
sigma2=-152.6;

t_1=log(0.95)/sigma1;
t_2=log(0.05)/sigma2;

% Simulación
t_S=1e-7;                   %tiempo de simulación
tF=0.04;                    %tiempo final de simulación 0
tF1=3e-7;                   %tiempo final de simulación 1
u=12;                       %entrada 12 [V]
TL=1e-5;                    %Torque inicial [Nm]
TLfin=1e-4;                 %Torque final [Nm]
TLi=1e-15;                  %Paso de cada Torque
jj=0;                       %indice

while TL<TLfin
    ii=0;                % indice
    X=-[0; 0];           % Vector de Omega y Wr
    TL=TL+jj*TLi;
    for t=0:t_S:tF1
        ii=ii+1;
        X=modmotor2(t_S, X, u, TL);
        x1(ii)=X(1);                  %Omega
    end
    if X(1)<0
        TL=TL-jj*TLi;
        break;
    end
    jj=jj+1;
end

% Vuelvo a simular con un nuevo tiempo final 1
ii=0;X=-[0; 0];
for t=0:t_S:tF
    ii=ii+1;
    X=modmotor2(t_S, X, u, TL);
    x1(ii)=X(1);%Omega
end

t=0:t_S:tF;
plot(t,x1,'r');title('Salida y, \omega_t');
xlabel('Tiempo [Seg.]');

% Función del Motor
function [X]=modmotor2(t_S, xant, accion, torque)
Laa=366e-6;
J=5e-9;
Ra=55.6;
B=0;
Ki=6.49e-3;
Km=6.53e-3;
TL=torque;
Va=accion;
h=1e-7;
omega=xant(1);
wp=xant(2);
for ii=1:t_S/h
wpp =(-wp*(Ra*J+Laa*B)-omega*(Ra*B+Ki*Km)+Va*Ki)/(J*Laa);
wp=wp+h*wpp;
wp=wp-(TL/J);
omega=omega+h*wp;
end
X=[omega,wp];
end
