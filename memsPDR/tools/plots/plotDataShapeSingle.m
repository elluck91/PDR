function plotDataShapeSingle(mCAL, mAL, SI, HI, plotFigH, plotShape, plotAlign, mColor, holdFlag)
%mCAL - uncalibrated data - nx3
%mAL - calibrated data nx3
%SI - scale matrix SI(mCal-HI)
% HI - hard iron 1x3
% plotFigH -  fig number
% plotShape to plot surf
% plotAlign, mColor, holdFlag
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Data on Sphere
%     plotFigH = 300;
%     plotShape=1;
    simSize=30;
    if plotFigH
        norUC = zeros(length(mCAL),1);
        for i = 1:length(mCAL)
            norUC(i) = norm(mAL(i,:));
        end
        R = mean(norUC);
%         R=50;
%         aUNCAL = CalDataAy(:,dataInd.aUNCALind); % factory calibrated accel output (not normalized)
%         mCAL = CalDataAy(:,dataInd.mCALind); % factory calibrated mag output
%         mAL = CalDataAy(:,dataInd.mALind); % factory calibrated mag output
%         %     Rmax = max(max(abs([mCAL mAL])));
%         Rmax=R;
%         figure(plotFigH); clf
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% Create Reference Sphere
%         [x,y,z] = sphere(simSize);
%         x2 = x .* 1 .* 1;
%         y2 = y .* 1 .* 1;
%         z2 = z .* 1 .* 1;
% 
%         SphereColor = [.7 .7 .7];
%         % surf(x2,y2,z2,'EdgeColor',[1 1 1],'FaceAlpha',0.15)
%         surf(x2,y2,z2,'EdgeColor',SphereColor, 'FaceColor', 'none')
%         hold on
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%         % plot(SolidGen(:,[1]),SolidGen(:,[2]),'.')
%         % plot3(SolidGen(:,[1]),SolidGen(:,[2]), SolidGen(:,[3]),'.'); hold on
%         plot3(aUNCAL(:,[1]),aUNCAL(:,[2]), aUNCAL(:,[3]),'pg', 'MarkerFaceColor', 'g', 'MarkerSize', 10)
%         axis equal
%         axis square
%         % 	axis off
%         axis vis3d
%         set(gca, 'Color', 'none')
%         xlabel('X (g)'); ylabel('Y (g)'); zlabel('Z (g)');
%         title('Accelerometer Sphere');
%         xlim([-1 1]); ylim([-1 1]); zlim([-1 1]);
 
        figure(plotFigH); 
        if ~holdFlag
            clf
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Create Reference Sphere
        [x,y,z] = sphere(simSize);
        x2 = x .* R .* 1;
        y2 = y .* R .* 1;
        z2 = z .* R .* 1;

        SphereColor = [1 .7 .7];
        % surf(x2,y2,z2,'EdgeColor',[1 1 1],'FaceAlpha',0.15)
        
%         hold on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % plot(SolidGen(:,[1]),SolidGen(:,[2]),'.')
        % plot3(SolidGen(:,[1]),SolidGen(:,[2]), SolidGen(:,[3]),'.'); hold on
        plot3(mCAL(:,[1]), mCAL(:,[2]), mCAL(:,[3]),'.', 'MarkerEdgeColor', mColor, 'MarkerFaceColor', mColor, 'MarkerSize', 10);hold on
        if plotAlign
            plot3(mAL(:,[1]),mAL(:,[2]), mAL(:,[3]),'.r', 'MarkerFaceColor', 'r') % turned off fro troubleshoot
        end
        surf(x2,y2,z2,'EdgeColor',SphereColor, 'FaceColor', 'none')
        
        axis equal
        axis square
        % 	axis off
        axis vis3d
        set(gca, 'Color', 'none')
        xlabel('X (\muT)'); ylabel('Y (\muT)'); zlabel('Z (\muT)');
        title('Magnetometer Sphere');
%         xlim([-Rmax Rmax]); ylim([-Rmax Rmax]); zlim([-Rmax Rmax]);
        
        
        if plotShape
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Gen sim Fit sphere
            simSize = simSize/2;
            [x,y,z] = sphere(simSize);
            x2 = x .* R .* 1;
            y2 = y .* R .* 1;
            z2 = z .* R .* 1;
            x2 = reshape(x2,(simSize+1).^2, 1); % convert to single column
            y2 = reshape(y2,(simSize+1).^2, 1); % convert to single column
            z2 = reshape(z2,(simSize+1).^2, 1); % convert to single column
            mSIM = [x2 y2 z2];
            calSize = size(mSIM,1);

            % mFITSIM = impaired distorted field from user cal fit estimation
            mFITSIM = (inv(SI)*mSIM')' + repmat(HI', calSize,1) ; % (distorted by SI HI)
            xsim = reshape(mFITSIM(:,1),(simSize+1), (simSize+1)); % convert to single column
            ysim = reshape(mFITSIM(:,2),(simSize+1), (simSize+1)); % convert to single column
            zsim = reshape(mFITSIM(:,3),(simSize+1), (simSize+1)); % convert to single column

            switch mColor
                case 'r'
                    SphereColor = [1 .7 .7];
                case 'g'
                    SphereColor = [.8 1 .8];
                case 'b'
                    SphereColor = [.7 .7 1];
                case 'c'
                    SphereColor = [.8 1 1];
                case 'y'
                    SphereColor = [1 1 .8];
                case 'k'
                    SphereColor = [.7 .7 .7];
            end            
            
            % surf(x2,y2,z2,'EdgeColor',[1 1 1],'FaceAlpha',0.15)
            surf(xsim,ysim,zsim,'EdgeColor',SphereColor, 'FaceColor', 'none')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        grid off
        axis equal
        
        set(gca,'ZDir','reverse', 'YDir','reverse'); % set frame to NED

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
