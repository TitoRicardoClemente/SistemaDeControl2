clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Motor CC - CASO 2 - Sistema de tres variables de estado
% ITEM 4 - Calculo de Torque

Laa=366e-6;
J=5e-9;
Ra=55.6;
Bm=0;
Ki=6.49e-3;
Km=6.53e-3;

% Defino las matrices de estados

A=[-Ra/Laa -Km/Laa 0; Ki/J -Bm/J 0; 0 1 0];
B=[1/Laa 0; 0 -1/J; 0 0];
C=[0 1 0];
D=[0 0];

% Calculo de los Autovalores de la Matriz A:
% obtengo lo mismo calculando los polos del denominador 
% roots(deno)
autov_A=eig(A);
lambda_1=autov_A(3); % polo más lento
lambda_2=autov_A(2); % polo más rápido

t_R=log(0.95)/lambda_1; % 3.379e-07/3 =~ 1e-7 coincide cone delta 
t_L=log(0.05)/lambda_2; % 0.019*2 =~ 0.04  con tiempo Final

% Simulación
t_S=1e-7;                   %tiempo de simulación
tF=0.07;                       %tiempo final de simulación en 5 segundos
% trate con 5 segundos pero me pareció mejor ver las diferencias entre los
% diferentes torques en un tiempo más pequeño, por eso los 0,07 segundos
% Tiene Dos entradas cuyo modulo se define a continuación
u=12;                       %Entrada de Tensión [V]
TLi=0.001;                   %Torque inicial [Nm]
TLfin=0.002;                 %Torque final [Nm]

% Vuelvo a simular con un nuevo tiempo final 1
h=tF/t_S;                     % cantidad de valores de simulacion 600000
t=linspace(0,tF,h);           % arreglo de datos de tiempo 
u=u*heaviside(t);             % cominza desde el primer momento a aplicarse
ia(1)=0;wr(1)=0;theta(1)=0;
jj=1;
while TLi<=TLfin              % vario el torque hasta un valor final
    tL=TLi*heaviside(t-0.01); % torque comienza en un tiempo diferente que la entrada u para ver la diferencia
    Xop=[0;0;0];              % punto de operación 
    Xp=[0;0;0];               % Matriz auxiliar para las variables de estado derivadas
    X=[0;0;0];                % Matriz de variable de estado 
    U=[0;0];                  % Matriz de entradas tensión y torque
    
    for ii=1 : h
        U(1)=u(ii);
        U(2)=tL(ii);
        Xp = A*(X-Xop) + B*U;
        X  = X + Xp*t_S;
        ia(ii)=X(1);
        wr(ii)=X(2);
        theta(ii)=X(3);
    end
    figure(1)
    subplot(1,4,1);plot(t,wr);legend(string(TLi));title('\omega - velocidad angular');hold on
    subplot(1,4,2);plot(t,tL);title('\tau - Torque');hold on
    subplot(1,4,3);plot(t,ia);title('i_a - Corriente');hold on
    TLR(jj)=TLi;
    TLi=TLi+0.0001;
    jj=jj+1;
end
figure(1)
subplot(1,4,4);plot(TLR);title('rampa de torques');hold on

% Coclusion
% =========
% Obtengo una familia de curvas que me muestran los valores para los que el
% torque dan valores positivos y negativos de frecuencia angular wr. Por lo
% cual se ve el Torque máximo en TLmax=1,4 [mNm]