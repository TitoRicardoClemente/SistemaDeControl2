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


%Funcion para solo tomar los valores necesarios, sin puntos muerto
[tiempo_S,omega_S,entrada,torque_S,corriente_S]=CurvaCondicionesInicialesNulas(tiempo_d,velovidad_d,corriente_d,tension_d,torque_d,length(tiempo_d));


% Aplico Metodo de Chen para calcular la corriente
% ---------------------------------------------------------
% Elijo 3 puntos equidistantes (en tiempo) en la grafica de la respuesta al
% escalon del voltaje (Tercera columna de excel):
% identifico tres puntos
t_inicial=0.05e-3;
[~,punto]=min(abs(t_inicial-tiempo_S));
t_t1=tiempo_S(punto); y1_v = corriente_S(punto);
[~,punto]=min(abs((t_inicial*2)-tiempo_S)); 
t_t2=tiempo_S(punto); y2_v = corriente_S(punto);
[~,punto]=min(abs((t_inicial*3)-tiempo_S)); 
t_t3=tiempo_S(punto); y3_v = corriente_S(punto);

t_t4=tiempo_S(end);y4_v=corriente_S(end);

figure(3)
plot(tiempo_S,corriente_S,'red');grid;hold on
plot([t_t1 t_t2 t_t3 t_t4],[y1_v y2_v y3_v y4_v],'*');hold on;
title('Curva Corriente original + puntos para Chen');
xlabel('Tiempo [segundos]');
ylabel('Corriente [Amp]');

% Siendo un sistema de segundo Orden, para identificarlo, debo de
% normalizar la entrada del sistema y ademas la salida correspondiente a la
% tension del Capacitor.

% Defino el Entrada Escalón del Sistema
opt=stepDataOptions; % normalizo el arreglo para que sea una entrada escalón
opt.StepAmplitud=1;
% Defino K a partir del cociente del ultimo valor de corriente sobre la amplitud del escalón:
K=corriente_S(end)/opt.StepAmplitud;
k1=(1/opt.StepAmplitud)*y1_v/K-1;
k2=(1/opt.StepAmplitud)*y2_v/K-1;
k3=(1/opt.StepAmplitud)*y3_v/K-1;

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
I_a_V_a=tf(K*[T_3 1],conv([T_2 1],[T_1 1]))

% sitema aproximado
step(I_a_V_a,'k');hold on
J=I_a_V_a.Numerator{1,1}(1,2)
B=I_a_V_a.Numerator{1,1}(1,3)
L=I_a_V_a.Denominator{1,1}(1,1)/J
R=(I_a_V_a.Denominator{1,1}(1,2)-L*B)/J
KmKi=1-R*B; Km=198,2; 
Ki=KmKi/Km


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
