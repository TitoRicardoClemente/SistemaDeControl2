clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingenier�a Electronica
% Sistema de Control II - 2024
% 1. Actividad Pr�ctica N�1 Representaci�n de sistemas y control PID
% ===================================================================
% Circuito RLC
% Ve: tensi�n de entrada [Volts]
% L: inductancia [Henrios]
% C: capacidad [Faradios]
% R: resistencia [Ohms]
% Vr: tensi�n de salida (en la resistencia) [Volts]
% i: corriente

% Variables de Estado de sistema el�ctrico
% Entrada u=Ve
% x1 = i ; x1p=(u-x2-x1*R)*(1/L)
% x2 = Vc ; x2p=(x1)*(1/C)
% Salida y=x1*R

% [x1p ; x2p] = [-R/L -1/L; 1/C 0]*[x1;x2] + [1/L;0] * u
% y = [R 0] * [x1;x2]

% Definic�n de las Matrices y los valores de Cada Variable
% Variables
R= 47;  %  47[Ohms]
L= 1e-6;  % 1 [uHy]
cap= 100e-9; % 100 [nF]
% Matrices
A= [-R/L -1/L; 1/cap 0];
B=[1/L; 0];
C=[R 0];
D=[0];

% Calculo de la  
[num,deno]=ss2tf(A,B,C,D);
G=tf(num,deno);

% Calculo de los Autovalores de la Matriz A:
% obtengo lo mismo calculando los polos del denominador 
% roots(deno)
autov_A=eig(A);
lambda_1=autov_A(1); % polo m�s r�pido
lambda_2=autov_A(2); % polo m�s lento

% constante de tiempo del polo m�s r�pido 95 %
tr=log(0.95)/lambda_1; % tr=1  nseg entonces tr=0.1 nseg 
% constante de tiempo del polo m�s lento 5%
tl=log(0.05)/lambda_2; % tl=14 useg entonces tl=100 useg

% defino el tiempo de integraci�n y tiempo final
tI=1e-9; tF=4e-3;
% calcular la cantidad de puntos que tomar� mi simulaci�n:
h=tF/tI;
% defino la cantidad de datos correspondiente al tiempo
% tiempo inicial=0, tiempo final=1e-9, cantidad de valores=4e6
t=linspace(0,tF,h); 

% Defino las variables y sus datos a guardar
u=[h];          % defino variable de entrada u 
i=[h];          % defino variable de estado x1
vc=[h];         % defino variable de estado x2
vr=[h];         % defino variable de salida y

% Variables de estados, inicializaci�n
X=[0; 0];     % x1 = 0 , x2 = 0 
Y=[0];        % y = 0

% inicializaci�n
Ve=12;          % tension m�xima de la se�al de entrada
tconmuta=1e-3;    % tiempo de subida y bajada, se�al de entrada


for j=1:1:h
    % Asigno el tiempo correspondiente
    t(j)=j*tI;
    % Eval�o si tengo la entrada en 12V o -12V
    if 0==(mod(t(j),tconmuta)) % veo si es multiplo de 1e-3
        Ve=-1*Ve;              % si es multiplo conmuto
    end
    
    % guardo el valor correspondiente a cada variable a graficar
    u(j)=Ve;
    i(j)=X(1);  
    vc(j)=X(2);
    vr(j)=Y(1);
    
    % ecuaciones deferenciales de primer orden del sistema monovariable
    Xp=A*X+B*u(j);  % Ecuaci�n de Estados
    X=X+tI*Xp;      % M�todo de Euler definido tI=1useg * dx
    Y=C*X;
end

figure(1);
subplot(3,1,1)
plot(t,i,'b','LineWidth', 2);title('x_1 = Corriente');xlabel('segundos [sec]');ylabel('Ampere')
subplot(3,1,2)
plot(t,vc,'r','LineWidth', 2);title('x_1 = V_C_t');xlabel('segundos [sec]');ylabel('Voltios')
subplot(3,1,3)
plot(t,u,'m','LineWidth', 2);title('Entrada U_t, V_e');xlabel('segundos [sec]');ylabel('Voltios')
xlabel('Tiempo [s]');

% La gr�fica muestra una tensi�n de carga en el capacitor, bastante r�pida 
% en el orden de los ts=1 useg, dando una conmutaci�n a plena carga de conmutaci�n
% Dada la baja resistencia de la carga R, genera una constante de tiempo
% tau=R*C