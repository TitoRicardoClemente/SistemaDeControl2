clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID
% ===================================================================
% Motor CC - CASO 2 - Sistema de tres variables de estado
% ITEM 5 - Modelo 
% Cargo los valores en cuatro arreglos:
tiempo_d = xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','A:A');
velovidad_d=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','B:B');
corriente_d=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','C:C');
tension_d=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','D:D');
torque_d=xlsread('Curvas_Medidas_Motor_2024.xls','Hoja1','E:E');

% Grafico las tres variables respecto al tiempo:
figure(1);
subplot(4,1,1);plot(tiempo_d,velovidad_d,'blue'); hold on
title('Curvas Datos Original');hold on
ylabel('\omega_r [rad/seg]');
xlabel('Tiempo [segundos]');
subplot(4,1,2);plot(tiempo_d,corriente_d,'red'); hold on
ylabel('i_a[Amper]');
xlabel('Tiempo [segundos]');
subplot(4,1,3);plot(tiempo_d,tension_d,'green'); hold on
ylabel('V [Volt]');
xlabel('Tiempo [segundos]');
subplot(4,1,4);plot(tiempo_d,torque_d,'magenta'); hold on
ylabel('\tau [Nm]');
xlabel('Tiempo [segundos]');


%Funcion para solo tomar los valores necesarios, sin puntos muerto
[tiempo_S,omega_S,entrada,torque_S,corriente_S]=CurvaCondicionesInicialesNulas(tiempo_d,velovidad_d,corriente_d,tension_d,torque_d,length(tiempo_d));


% Aplico Metodo de Chen para calcular la velocidad angualar
% ---------------------------------------------------------
% Elijo 3 puntos equidistantes (en tiempo) en la grafica de la respuesta al
% escalon del voltaje (Tercera columna de excel):
% identifico tres puntos
t_inicial=0.05e-3;
[~,punto]=min(abs(t_inicial-tiempo_S));
t_t1=tiempo_S(punto); y1_v = omega_S(punto);
[~,punto]=min(abs((t_inicial*2)-tiempo_S)); 
t_t2=tiempo_S(punto); y2_v = omega_S(punto);
[~,punto]=min(abs((t_inicial*3)-tiempo_S)); 
t_t3=tiempo_S(punto); y3_v = omega_S(punto);

%Ademas, tambien debo elegir un cuarto punto para normalizar la ganancia:
[~,punto]=min(abs(tiempo_S(end)-tiempo_S));
t_t4 = tiempo_S(punto);        y4_v = omega_S(punto);

figure(2)
plot(tiempo_S,omega_S,'blue');hold on
plot([t_t1 t_t2 t_t3 t_t4],[y1_v y2_v y3_v y4_v],'*');hold on;
% Siendo un sistema de segundo Orden, para identificarlo, debo de
% normalizar la entrada del sistema y ademas la salida correspondiente a la
% tension del Capacitor.

% Defino el Entrada Escalón del Sistema
opt=stepDataOptions; % normalizo el arreglo para que sea una entrada escalón
opt.StepAmplitud=1;
% Defino K a partir del cociente del ultimo valor de tensión sobre la amplitud:
K=y4_v/opt.StepAmplitud;
k1=(y1_v/K)-1;
k2=(y2_v/K)-1;
k3=(y3_v/K)-1;

% Ecuaciones desarrolladas bajo el supesto T1<T2 y alfa1<alfa2
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3; 
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2)); 
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2)); 
beta=(k1+alfa2)/(alfa1-alfa2);

% Remplazo en los valores de las constantes de tiempo T1, T2 y T3:
% si se toma los valor completos se resta el tiempo muerto o sea 10 ms
T_1=-t_t1/log(alfa1); 
T_2=-t_t1/log(alfa2); 
T_3=beta*(T_1-T_2)+T_1; 

% Sistema Aproximado Final:
W_r_V_a=tf(K*[T_3 1],conv([T_2 1],[T_1 1]))
W_r_V_a=zpk(W_r_V_a)

% sitema aproximado
step(W_r_V_a,'r')
title('Curva \omega_r original (Azul) + puntos para Chen + Curva Aproximada (Rojo)');
xlabel('Tiempo [segundos]');
ylabel('\omega [rad/seg]');

function [X,Y,Z,T,I]=CurvaCondicionesInicialesNulas(t,wr,ia,u,Tl,iteracion)
    t_aux=[];
    wr_aux=[];
    u_aux=[];
    ia_aux=[];
    Tl_aux=[];
    j=1;
    for i=1:1:iteracion
      if wr(i+1)~=0
          if u(i)==12 && Tl(i)==0
              if j==1
                  t_inic=t(i);% valor inicial
              end
              t_aux(j)=t(i)-t_inic;
              wr_aux(j)=wr(i);
              u_aux(j)=u(i);
              Tl_aux(j)=Tl(i);
              ia_aux(j)=ia(i);
              j=j+1;
          else
              break
          end
      end
    end
X=t_aux;
Y=wr_aux;
Z=u_aux;
T=Tl_aux;
I=ia_aux;
end
